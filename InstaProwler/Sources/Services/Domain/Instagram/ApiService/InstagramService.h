//
//  InstagramService.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 24/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InstagramService <NSObject>

- (void)searchForUserWithString:(NSString *)searchString
                   successBlock:(void(^)(NSArray *))successBlock // array of InstagramUser
                     errorBlock:(void(^)(NSError *error))errorBlock;

- (void)recentMediaForUserWithId:(NSString *)userId
                           count:(NSNumber *)count
                           maxId:(NSString *)maxId
                    successBlock:(void(^)(NSArray *items/*InstagramMediaItem*/, NSString *nextMaxId))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

@end
