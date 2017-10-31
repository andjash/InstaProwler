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
#import "InstagramCacheService.h"
#import "Reachability.h"
#import "InstagramMediaItem.h"

#import "NSError+Additions.h"

NSString * const kInstagramMediaItemsModelStateChangedNotification = @"kInstagramMediaItemsModelStateChangedNotification";
NSString * const kInstagramMediaItemsModelChangedNotification = @"kInstagramMediaItemsModelChangedNotification";

NSString * const kInstagramMediaItemsModelErrorDomain = @"kInstagramMediaItemsModelErrorDomain";

static const NSUInteger kLoadStepSize = 10;
static const NSUInteger kMaxCommentsCount = 5;

@interface InstagramMediaItemsModelImpl ()

@property (nonatomic, strong) NSString *nextMaxId;
@property (nonatomic, strong) InstagramUser *currentUser;
@property (nonatomic, strong) NSString *currentSearchString;
@property (nonatomic, strong) Reachability *reachability;

@property (nonatomic, assign, readwrite) InstagramMediaItemsModelState state;
@property (nonatomic, strong, readwrite) NSArray *mediaItems;
@property (nonatomic, strong, readwrite) NSError *lastError;
@property (nonatomic, assign, readwrite) BOOL hasMoreItems;

@property (nonatomic, weak) id<InstagramService> instagramService;
@property (nonatomic, weak) id<InstagramCacheService> cacheService;

@end

@implementation InstagramMediaItemsModelImpl
objection_register_singleton(InstagramMediaItemsModelImpl)
objection_requires(@"instagramService", @"cacheService");

#pragma mark - Objection

- (void)awakeFromObjection {
    [super awakeFromObjection];
    self.hasMoreItems = YES;
    self.mediaItems = @[];
    self.reachability = [Reachability reachabilityForInternetConnection];
}

#pragma mark - Public

- (void)loadNextPageForSearchString:(NSString *)searchString {
    if (![self.currentSearchString isEqualToString:searchString] || !self.reachability.isReachable) {
        self.currentSearchString = searchString;
        self.nextMaxId = nil;
        self.currentUser = nil;
        self.mediaItems = @[];
        self.hasMoreItems = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramMediaItemsModelChangedNotification object:nil];
    }
    
    
    if (self.reachability.isReachable) {
        [self loadnextPageWithCurrentState];
    } else {
        self.state = InstagramMediaItemsModelStateProgress;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.cacheService getPostsWithUserName:self.currentSearchString
                                withCompletionBlock:^(NSArray *items) {
                                    self.hasMoreItems = NO;
                                    self.mediaItems = items;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramMediaItemsModelChangedNotification object:nil];
                                    self.state = InstagramMediaItemsModelStateIdle;
            }];
        });
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

#pragma mark - Private

- (void)loadCommentsForMediaItems:(NSArray *)items
                  completionBlock:(void(^)(void))completion {
    __block NSInteger itemsLoaded = 0;
    
    void (^proceedBlock)(void) = ^void() {
        itemsLoaded++;
        if (itemsLoaded == [items count]) {
            completion();
        }
    };
    
    for (InstagramMediaItem *item in items) {
        [self.instagramService commentsForMediaItemId:item.itemId successBlock:^(NSArray *items) {
            if ([items count] > kMaxCommentsCount) {
                item.comments = [items subarrayWithRange:NSMakeRange(0, kMaxCommentsCount)];
            } else {
                item.comments = items;
            }
            proceedBlock();
        } errorBlock:^(NSError *error) {
            proceedBlock();
        }];
    }
}

- (void)loadnextPageWithCurrentState {
    self.state = InstagramMediaItemsModelStateProgress;
    void (^loadRecentMediaBlock)(void) = ^void() {
        [self.instagramService recentMediaForUserWithId:self.currentUser.userId
                                                  count:@(kLoadStepSize)
                                                  maxId:self.nextMaxId
                                           successBlock:^(NSArray *items, NSString *nextMaxId) {
                                               [self loadCommentsForMediaItems:items completionBlock:^{
                                                   if ([nextMaxId length] == 0) {
                                                       self.hasMoreItems = NO;
                                                   }
                                                   
                                                   for (InstagramMediaItem *post in items) {
                                                       [self.cacheService storePost:post withCompletionBlock:^{}];
                                                   }
                                                   
                                                   self.nextMaxId = nextMaxId;
                                                   NSMutableArray *newItems = [self.mediaItems mutableCopy];
                                                   [newItems addObjectsFromArray:items];
                                                   self.mediaItems = newItems;
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kInstagramMediaItemsModelChangedNotification object:nil];
                                                   self.state = InstagramMediaItemsModelStateIdle;
                                               }];
                                           } errorBlock:^(NSError *error) {
                                               self.lastError = error;
                                               self.state = InstagramMediaItemsModelStateIdle;
                                           }];
    };
    
    if (!self.currentUser) {
        [self.instagramService searchForUserWithString:self.currentSearchString successBlock:^(NSArray *users) {
            for (InstagramUser *user in users) {
                if ([self.currentSearchString isEqualToString:user.username]) {
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

@end
