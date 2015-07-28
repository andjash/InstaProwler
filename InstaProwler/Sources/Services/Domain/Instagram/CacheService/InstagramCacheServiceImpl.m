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
static const NSUInteger kCachePostsCount = 100;
static const NSUInteger kCachePostsCountTreshold = 20;
static NSString * const kItemsCountDefaultsKey = @"kItemsCountDefaultsKey";

@interface InstagramCacheServiceImpl ()

@property (nonatomic, strong) id<InstagramCacheStorage> cacheStorage;
@property (nonatomic, assign) NSInteger itemsCount;

@end

@implementation InstagramCacheServiceImpl
objection_register_singleton(InstagramCacheServiceImpl)
objection_requires(@"cacheStorage")

- (void)awakeFromObjection {
    [super awakeFromNib];
    
    self.itemsCount = [[NSUserDefaults standardUserDefaults] integerForKey:kItemsCountDefaultsKey];
}

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
    self.itemsCount++;
    if (self.itemsCount > kCachePostsCount + kCachePostsCountTreshold) {
        [self.cacheStorage removeOldPosts:kCachePostsCount];
        self.itemsCount = kCachePostsCount;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.itemsCount forKey:kItemsCountDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)getPostsWithUserName:(NSString *)username withCompletionBlock:(void (^)(NSArray *))completionBlock {
    [self.cacheStorage getPostsWithUserName:username withCompletionBlock:completionBlock];
}


@end
