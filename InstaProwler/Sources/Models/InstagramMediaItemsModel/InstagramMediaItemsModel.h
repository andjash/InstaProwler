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

extern NSString * const kInstagramMediaItemsModelErrorDomain;

@protocol InstagramMediaItemsModel <NSObject>

@property (nonatomic, assign, readonly) InstagramMediaItemsModelState state;
@property (nonatomic, strong, readonly) NSArray *mediaItems;
@property (nonatomic, strong, readonly) NSError *lastError;
@property (nonatomic, assign, readonly) BOOL hasMoreItems;


- (void)loadNextPageForSearchString:(NSString *)searchString;
- (void)loadNextPage;

@end
