//
//  InstagramCacheService.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstagramCacheService <NSObject>

- (void)getImageFromCacheWithUrl:(NSString *)url
                 completionBlock:(void(^)(UIImage *image))completionBlock;
- (void)storeImageToCache:(UIImage *)image withUrl:(NSString *)url;

@end
