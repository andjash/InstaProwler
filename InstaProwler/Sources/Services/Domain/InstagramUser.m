//
//  InstagramUser.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "InstagramUser.h"

@implementation InstagramUser

#pragma mark - Public

+ (instancetype)fromDictionary:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    InstagramUser *user = [InstagramUser new];
    user.username = dict[@"username"];
    user.userId = dict[@"id"];
    return user;
}

#pragma marl - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p Username = %@ UserId = %@", [self class], self, self.username, self.userId];
}

@end
