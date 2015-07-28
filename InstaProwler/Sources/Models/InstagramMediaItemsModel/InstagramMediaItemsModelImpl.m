//
//  InstagramMediaItemsModelImpl.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "InstagramMediaItemsModelImpl.h"
#import "Objection.h"
#import "InstagramService.h"
#import "InstagramUser.h"

#import "NSError+Additions.h"

NSString * const kInstagramMediaItemsModelStateChangedNotification = @"kInstagramMediaItemsModelStateChangedNotification";
NSString * const kInstagramMediaItemsModelChangedNotification = @"kInstagramMediaItemsModelChangedNotification";

NSString * const kInstagramMediaItemsModelErrorDomain = @"kInstagramMediaItemsModelErrorDomain";

static const NSUInteger kLoadStepSize = 5;

@interface InstagramMediaItemsModelImpl ()

@property (nonatomic, strong) NSString *nextMaxId;
@property (nonatomic, strong) InstagramUser *currentUser;
@property (nonatomic, strong) NSString *currentSearchString;

@property (nonatomic, assign, readwrite) InstagramMediaItemsModelState state;
@property (nonatomic, strong, readwrite) NSArray *mediaItems;
@property (nonatomic, strong, readwrite) NSError *lastError;
@property (nonatomic, assign, readwrite) BOOL hasMoreItems;

@property (nonatomic, weak) id<InstagramService> instagramService;

@end

@implementation InstagramMediaItemsModelImpl
objection_register_singleton(InstagramMediaItemsModelImpl)
objection_requires(@"instagramService");

#pragma mark - Objection

- (void)awakeFromObjection {
    [super awakeFromObjection];
    self.hasMoreItems = YES;
    self.mediaItems = @[];
}

#pragma mark - Public

- (void)loadNextPageForSearchString:(NSString *)searchString {
    if (![self.currentSearchString isEqualToString:searchString]) {
        self.currentSearchString = searchString;
        self.nextMaxId = nil;
        self.currentUser = nil;
        self.mediaItems = @[];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramMediaItemsModelChangedNotification object:nil];
    }
    
    self.state = InstagramMediaItemsModelStateProgress;
    
    void (^loadRecentMediaBlock)() = ^void() {
        [self.instagramService recentMediaForUserWithId:self.currentUser.userId
                                                  count:@(kLoadStepSize)
                                                  maxId:self.nextMaxId
                                           successBlock:^(NSArray *items, NSString *nextMaxId) {
                                               if ([nextMaxId length] == 0) {
                                                   self.hasMoreItems = NO;
                                               }
                                               
                                               self.nextMaxId = nextMaxId;
                                               NSMutableArray *newItems = [self.mediaItems mutableCopy];
                                               [newItems addObjectsFromArray:items];
                                               self.mediaItems = newItems;
                                               [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramMediaItemsModelChangedNotification object:nil];
                                               self.state = InstagramMediaItemsModelStateIdle;
        } errorBlock:^(NSError *error) {
            self.lastError = error;
            self.state = InstagramMediaItemsModelStateIdle;
        }];
    };
    
    if (!self.currentUser) {
        [self.instagramService searchForUserWithString:self.currentSearchString successBlock:^(NSArray *users) {
            for (InstagramUser *user in users) {
                if ([searchString isEqualToString:user.username]) {
                    self.currentUser = user;
                    break;
                }
            }
            
            if (self.currentUser) {
                loadRecentMediaBlock();
            } else {
                self.lastError = [NSError errorWithDomain:kInstagramMediaItemsModelErrorDomain
                                                     code:kInstagramMediaItemsModelNoSuchUser
                                                 userInfo:nil];
                self.state = InstagramMediaItemsModelStateIdle;
            }
        } errorBlock:^(NSError *error) {
            self.lastError = error;
            self.state = InstagramMediaItemsModelStateIdle;
        }];
    } else {
        loadRecentMediaBlock();
    }
}

- (void)loadNextPage {
    [self loadNextPageForSearchString:self.currentSearchString];
}

#pragma mark - Properties

- (void)setState:(InstagramMediaItemsModelState)state {
    if (_state == state) {
        return;
    }
    
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramMediaItemsModelStateChangedNotification object:nil];
}

@end
