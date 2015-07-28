//
//  InstagramMediaItem.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InstagramUser;

@interface InstagramMediaItemComment : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) InstagramUser *author;

+ (instancetype)fromDictionary:(NSDictionary *)dict;

@end

@interface InstagramMediaItem : NSObject

@property (nonatomic, strong) InstagramUser *author;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *imageUrlString;
@property (nonatomic, strong) NSArray *comments; // array of InstagramMediaItemComment
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *originalJson;

+ (instancetype)fromDictionary:(NSDictionary *)dict;

@end



