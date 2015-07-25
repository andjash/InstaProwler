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

static NSString * const kInstagramClientId = @"5475c7bd0ee849c6a53c262b4d1b54f6";
static NSString * const kUserRecentsUrlFormat = @"https://api.instagram.com/v1/users/%@/media/recent/?client_id=%@";
static NSString * const kSearchUserUrlFormat = @"https://api.instagram.com/v1/users/search?q=%@&client_id=%@";

@interface InstagramServiceImpl ()

@property (nonatomic, weak) id<HttpService> httpService;

@end

@implementation InstagramServiceImpl
objection_register_singleton(InstagramServiceImpl)
objection_requires(@"httpService")

#pragma mark - Public

- (void)searchForUserWithString:(NSString *)searchString
                   successBlock:(void(^)(NSArray *))successBlock
                     errorBlock:(void(^)(NSError *error))errorBlock {
    RequestParameters *rp = [RequestParameters new];
    rp.url = [NSURL URLWithString:[NSString stringWithFormat:kSearchUserUrlFormat, searchString, kInstagramClientId]];
    rp.method = @"GET";
    
    ExecutionParameters *ep = [ExecutionParameters new];
    
    [ep setSuccessBlock:^(NSData *response) {
        NSError *parsingError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:response
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&parsingError];
        
        NSArray *userList = responseDict[@"data"];
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:[userList count]];
        
        for (NSDictionary *userDict in userList) {
            InstagramUser *user = [InstagramUser new];
            user.username = userDict[@"username"];
            user.userId = userDict[@"id"];
            [result addObject:user];
        }
        
        successBlock(result);
    }];
    
    [ep setErrorBlock:errorBlock];
    [self.httpService performRequestWithExecutionParameters:ep requestParameters:rp];
    
}

@end
