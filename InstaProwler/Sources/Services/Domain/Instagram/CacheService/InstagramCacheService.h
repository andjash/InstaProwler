//
//  InstagramCacheService.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstagramMediaItem;

@protocol InstagramCacheService <NSObject>

- (void)getImageFromCacheWithUrl:(NSString *)url
                 completionBlock:(void(^)(UIImage *image))completionBlock;
- (void)storeImageToCache:(UIImage *)image withUrl:(NSString *)url;

- (void)storePost:(InstagramMediaItem *)post withCompletionBlock:(void (^)(void))completionBlock;
- (void)getPostsWithUserName:(NSString *)username withCompletionBlock:(void (^)(NSArray *))completionBlock;

@end
