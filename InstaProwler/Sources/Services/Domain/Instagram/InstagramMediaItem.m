//
//  InstagramMediaItem.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "InstagramMediaItem.h"
#import "InstagramUser.h"

@implementation InstagramMediaItemComment

+ (instancetype)fromDictionary:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    InstagramMediaItemComment *item = [InstagramMediaItemComment new];
    item.author = [InstagramUser fromDictionary:dict[@"from"]];
    item.commentId = dict[@"id"];
    item.text = dict[@"text"];
    
    NSNumber *creationTime = dict[@"created_time"];
    item.creationDate = [NSDate dateWithTimeIntervalSince1970:[creationTime doubleValue]];
    
    return item;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p\r    author = %@\r    Id = %@\r    Creation date = %@\r    Text = %@", [self class], self, _author, _commentId, _creationDate, _text];
}

@end

@implementation InstagramMediaItem

+ (instancetype)fromDictionary:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    InstagramMediaItem *item = [InstagramMediaItem new];
    item.author = [InstagramUser fromDictionary:dict[@"user"]];
    item.itemId = dict[@"id"];
    
    NSNumber *creationTime = dict[@"created_time"];
    item.creationDate = [NSDate dateWithTimeIntervalSince1970:[creationTime doubleValue]];
    
    NSDictionary *imagesDict = dict[@"images"];
    NSDictionary *stdImageDict = imagesDict[@"standard_resolution"];
    item.imageUrlString = stdImageDict[@"url"];

    return item;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %p\r    author = %@\r    Id = %@\r    Creation date = %@\r    Image url = %@\r    Comments = %@", [self class], self, _author, _itemId, _creationDate, _imageUrlString, _comments];
}

@end
