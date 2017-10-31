//
//  CoreDataInstagramCacheStorage.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "CoreDataInstagramCacheStorage.h"
#import "Objection.h"
#import "CachedInstagramPost.h"
#import "InstagramMediaItem.h"
#import "InstagramUser.h"

@import CoreData;

@interface CoreDataInstagramCacheStorage ()

@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation CoreDataInstagramCacheStorage
objection_register(CoreDataInstagramCacheStorage)

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.queue = dispatch_queue_create("andjash.instaprowler.cache_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Properties

- (NSManagedObjectContext *)context {
    if (_context != nil) {
        return _context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self coordinator];
    if (coordinator != nil) {
        _context =  [[NSManagedObjectContext alloc] init];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    return _context;
}
- (NSPersistentStoreCoordinator *)coordinator {
    if (_coordinator != nil) {
        return _coordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FavoriteOperations.sqlite"];
    NSError *error = nil;
    
    [self deleteOldVersionOfStoreIfRequired:storeURL];
    
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self model]];
    if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unable to NSPersistentStoreCoordinator %@, %@", error, [error userInfo]);
    }
    
    return _coordinator;
}

- (NSManagedObjectModel *)model {
    if (_model != nil) {
        return _model;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"InstagramCache" withExtension:@"momd"];
    _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _model;
}

#pragma mark - Public

- (void)setImage:(UIImage *)image withUrl:(NSString *)url withCompletionBlock:(void (^)(void))completionBlock {
    dispatch_async(self.queue, ^{
        [self getCachedPostWithUrl:url withCompletionBlock:^(CachedInstagramPost *cachedPost) {
            if (!cachedPost) {
                return;
            }
            cachedPost.imageData = UIImagePNGRepresentation(image);
            
            NSError *error = nil;
            [self.context save:&error];
            if (error) {
                NSLog(@"Error while saving image %@", error);
            }
            [self.context reset];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock();
                }
            });
        }];
    });
}

- (void)getImageWithUrl:(NSString *)url withCompletionBlock:(void (^)(UIImage *))completionBlock {
    dispatch_async(self.queue, ^{
        [self getCachedPostWithUrl:url withCompletionBlock:^(CachedInstagramPost *cachedPost) {
            UIImage *image = [UIImage imageWithData:cachedPost.imageData];
            if (image) {
                image = [UIImage imageWithCGImage:image.CGImage
                                            scale:[UIScreen mainScreen].scale
                                      orientation:image.imageOrientation];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(image);
                }
            });
        }];
    });
}

- (void)storePost:(InstagramMediaItem *)post withCompletionBlock:(void (^)(void))completionBlock {
    dispatch_async(self.queue, ^{
        [self getCachedPostWithId:post.itemId withCompletionBlock:^(CachedInstagramPost *cachedPost) {
            if (cachedPost) {
                cachedPost.postDate = post.creationDate;
                cachedPost.savedDate = [NSDate date];
                if (![cachedPost.imageUrl isEqualToString:post.imageUrlString]) {
                    cachedPost.imageData = nil;
                    cachedPost.imageUrl = post.imageUrlString;
                }
                cachedPost.userName = post.author.username;
                cachedPost.postJson = post.originalJson;
            } else {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramPost class])
                                                                     inManagedObjectContext:self.context];
                CachedInstagramPost *result = [[CachedInstagramPost alloc] initWithEntity:entityDescription
                                                           insertIntoManagedObjectContext:self.context];
                
                result.postId = post.itemId;
                result.imageUrl = post.imageUrlString;
                result.postJson = post.originalJson;
                result.userName = post.author.username;
                result.postDate = post.creationDate;
                result.savedDate = [NSDate date];
            }
            
            NSError *error = nil;
            [self.context save:&error];
            if (error) {
                NSLog(@"Error while saving post %@", error);
            }
            [self.context reset];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock();
                }
            });
        }];
    });
}

- (void)getPostsWithUserName:(NSString *)username withCompletionBlock:(void (^)(NSArray *))completionBlock {
    dispatch_async(self.queue, ^{
        [self getCachedPostsWithUserName:username withCompletionBlock:^(NSArray *posts) {
            NSMutableArray *result = [NSMutableArray arrayWithCapacity:[posts count]];
            for (CachedInstagramPost *cachedPost in posts) {
                
                if (!cachedPost.imageData) {
                    continue;
                }
                
                NSError *parsingError = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[cachedPost.postJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&parsingError];
                if (parsingError) {
                    continue;
                }
                
                InstagramMediaItem *item = [InstagramMediaItem fromDictionary:dict];
                [result addObject:item];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(result);
                }
            });
        }];
    });
}


- (void)removeOldPosts:(NSUInteger)postsCountToLeave {
    dispatch_async(self.queue, ^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramPost class])
                                                  inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];
    
        NSError *error;
        NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedObjects count] > postsCountToLeave) {
            NSArray *sorted = [fetchedObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj2 savedDate] compare:[obj1 savedDate]];
            }];
            
            
            NSArray *toRemove = [sorted subarrayWithRange:NSMakeRange(postsCountToLeave, [sorted count] - postsCountToLeave)];
            
            for (CachedInstagramPost *post in toRemove) {
                [self.context deleteObject:post];
            }
            
            [self.context save:&error];
            if (error) {
                NSLog(@"Error while saving deleted operations %@", error);
            }
        }
        
    });
}

#pragma mark - Private

- (void)getCachedPostWithUrl:(NSString *)url withCompletionBlock:(void (^)(CachedInstagramPost *))completionBlock {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramPost class])
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"imageUrl == %@",
                              url];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        completionBlock(nil);
    } else {
        completionBlock([fetchedObjects firstObject]);
    }
}

- (void)getCachedPostWithId:(NSString *)postId withCompletionBlock:(void (^)(CachedInstagramPost *))completionBlock {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramPost class])
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postId == %@",
                              postId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        completionBlock(nil);
    } else {
        completionBlock([fetchedObjects firstObject]);
    }
}

- (void)getCachedPostsWithUserName:(NSString *)username withCompletionBlock:(void (^)(NSArray *))completionBlock {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramPost class])
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userName == %@",
                              username];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil || [fetchedObjects count] == 0) {
        completionBlock(nil);
    } else {
        completionBlock(fetchedObjects);
    }
}

- (void)deleteOldVersionOfStoreIfRequired:(NSURL *)storeURL {
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSDictionary *existingStoreMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeURL error:&error];
        BOOL forceDeletionRequired = NO;
        if (!existingStoreMetadata) {
            NSLog(@"No metadata found for existing store at path: %@", [storeURL path]);
            forceDeletionRequired = YES;
        }
        
        if (error) {
            NSLog(@"Error whle accessing metadata: %@", error);
            forceDeletionRequired = YES;
        }
        
        if (forceDeletionRequired) {
            NSLog(@"Error occured. Force deletion of old-version model is required");
        }
        
        if (forceDeletionRequired || ![self.model isConfiguration:nil compatibleWithStoreMetadata:existingStoreMetadata]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:[storeURL path] error:&error]) {
                NSLog(@"Unable to delete old-version store at path: %@", [storeURL path]);
                NSLog(@"Error: %@", error);
                NSLog(@"Subsequent behaviour is unpredictable");
            } else {
                NSLog(@"Old-version of store successfully deleted");
            }
        }
    }
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
