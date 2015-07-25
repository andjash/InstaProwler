//
//  InstagramMediaItemsModel.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, InstagramMediaItemsModelState) {
    InstagramMediaItemsModelStateEmpty,
    InstagramMediaItemsModelStateProgress,
    InstagramMediaItemsModelStateIdle,
};

extern NSString * const kInstagramMediaItemsModelStateChangedNotification;

@protocol InstagramMediaItemsModel <NSObject>

@property (nonatomic, assign, readonly) InstagramMediaItemsModelState state;
@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSError *lastError;


- (void)loadNextPageForsearchString:(NSString *)searchString;

@end
