//
//  InstagramServiceImpl.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 24/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "InstagramServiceImpl.h"
#import "Objection.h"
#import "HttpService.h"
#import "InstagramUser.h"
#import "QueueService.h"
#import "InstagramMediaItem.h"

static NSString * const kInstagramClientId = @"5475c7bd0ee849c6a53c262b4d1b54f6";
static NSString * const kUserRecentMediaUrlFormat = @"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@";
static NSString * const kSearchUserUrlFormat = @"https://api.instagram.com/v1/users/search?q=%@&client_id=%@";

@interface InstagramServiceImpl ()

@property (nonatomic, weak) id<HttpService> httpService;
@property (nonatomic, weak) id<QueueService> queueService;

@end

@implementation InstagramServiceImpl
objection_register_singleton(InstagramServiceImpl)
objection_requires(@"httpService", @"queueService")

#pragma mark - Public

- (void)searchForUserWithString:(NSString *)searchString
                   successBlock:(void(^)(NSArray *))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    RequestParameters *rp = [RequestParameters new];
    rp.url = [NSURL URLWithString:[NSString stringWithFormat:kSearchUserUrlFormat, searchString, kInstagramClientId]];
    rp.method = @"GET";
    
    ExecutionParameters *ep = [ExecutionParameters new];
    
    [ep setSuccessBlock:^(NSData *response) {
        [self.queueService postBlockInBackgroundSerialQueue:^{
            NSError *parsingError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&parsingError];
            
            if (parsingError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(parsingError);
                });
                return;
            }
            
            NSArray *userList = responseDict[@"data"];
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:[userList count]];
            
            for (NSDictionary *userDict in userList) {
                InstagramUser *user = [InstagramUser fromDictionary:userDict];
                if (user) {
                    [result addObject:user];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(result);
            });
        }];
        
    }];
    
    [ep setErrorBlock:errorBlock];
    [self.httpService performRequestWithExecutionParameters:ep requestParameters:rp];
}

- (void)recentMediaForUserWithId:(NSString *)userId
                           count:(NSNumber *)count
                           maxId:(NSString *)maxId
                    successBlock:(void(^)(NSArray *items/*InstagramMediaItem*/, NSString *nextMaxId))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock {
    RequestParameters *rp = [RequestParameters new];
    
    NSMutableString *urlString = [NSMutableString string];
    [urlString appendFormat:kUserRecentMediaUrlFormat, userId, kInstagramClientId];
    
    if (count) {
        [urlString appendFormat:@"&count=%@", count];
    }
    
    if (maxId) {
        [urlString appendFormat:@"&max_id=%@", maxId];
    }
    
    rp.url = [NSURL URLWithString:urlString];
    rp.method = @"GET";
    
    ExecutionParameters *ep = [ExecutionParameters new];
    
    [ep setSuccessBlock:^(NSData *response) {
        [self.queueService postBlockInBackgroundSerialQueue:^{
            NSError *parsingError = nil;
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&parsingError];
            if (parsingError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(parsingError);
                });
                return;
            }
            
            NSArray *itemsDicts = responseDict[@"data"];
            NSDictionary *paginationDict = responseDict[@"pagination"];
            NSString *nextMaxId = paginationDict[@"next_max_id"];
            
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:[itemsDicts count]];
            
            for (NSDictionary *dict in itemsDicts) {
                InstagramMediaItem *mediaItem = [InstagramMediaItem fromDictionary:dict];
                if (mediaItem) {
                    [result addObject:mediaItem];
                }
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(result, nextMaxId);
            });
        }];
    }];
    
    [ep setErrorBlock:errorBlock];
    [self.httpService performRequestWithExecutionParameters:ep requestParameters:rp];
}


@end
