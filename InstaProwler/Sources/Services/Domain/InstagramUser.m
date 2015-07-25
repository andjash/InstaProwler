//
//  InstagramUser.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "InstagramUser.h"

@implementation InstagramUser

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p Username = %@ UserId = %@", [self class], self, self.username, self.userId];
}

@end
