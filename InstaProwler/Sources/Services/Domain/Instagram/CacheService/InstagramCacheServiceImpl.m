//
//  InstagramCacheServiceImpl.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "InstagramCacheServiceImpl.h"
#import "Objection.h"
#import "InstagramCacheStorage.h"
#import "InstagramMediaItem.h"

@interface InstagramCacheServiceImpl ()

@property (nonatomic, strong) id<InstagramCacheStorage> cacheStorage;

@end

@implementation InstagramCacheServiceImpl
objection_register_singleton(InstagramCacheServiceImpl)
objection_requires(@"cacheStorage")

#pragma mark - Public 

- (void)getImageFromCacheWithUrl:(NSString *)url
                 completionBlock:(void(^)(UIImage *image))completionBlock {
    [self.cacheStorage getImageWithUrl:url withCompletionBlock:completionBlock];
}

- (void)storeImageToCache:(UIImage *)image withUrl:(NSString *)url {
    [self.cacheStorage setImage:image withUrl:url withCompletionBlock:nil];
}

- (void)storePost:(InstagramMediaItem *)post withCompletionBlock:(void (^)())completionBlock {
    [self.cacheStorage storePost:post withCompletionBlock:completionBlock];
}
- (void)getPostsWithUserName:(NSString *)username withCompletionBlock:(void (^)(NSArray *))completionBlock {
    [self.cacheStorage getPostsWithUserName:username withCompletionBlock:completionBlock];
}


@end
