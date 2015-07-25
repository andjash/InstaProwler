//
//  InstagramUser.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramUser : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userId;

+ (instancetype)fromDictionary:(NSDictionary *)dict;

@end
