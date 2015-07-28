//
//  CoreDataInstagramCacheStorage.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "CoreDataInstagramCacheStorage.h"
#import "Objection.h"
#import "CachedInstagramImage.h"

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

- (void)setImage:(UIImage *)image withUrl:(NSString *)url withCompletionBlock:(void (^)())completionBlock {
    dispatch_async(self.queue, ^{
        [self getCachedImageWithUrl:url withCompletionBlock:^(CachedInstagramImage *cachedImage) {
            CachedInstagramImage *result = nil;
            if (cachedImage) {
                cachedImage.imageData = UIImagePNGRepresentation(image);
                cachedImage.dateSaved = [NSDate date];
                result = cachedImage;
            } else {
                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramImage class])
                                                                     inManagedObjectContext:self.context];
                result = [[CachedInstagramImage alloc] initWithEntity:entityDescription
                                                             insertIntoManagedObjectContext:self.context];
                
                result.imageData = UIImagePNGRepresentation(image);
                result.imageUrl = url;
                result.dateSaved = [NSDate date];
            }
            
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
        [self getCachedImageWithUrl:url withCompletionBlock:^(CachedInstagramImage *cachedImage) {
            UIImage *image = [UIImage imageWithData:cachedImage.imageData];
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

#pragma mark - Private

- (void)getCachedImageWithUrl:(NSString *)url withCompletionBlock:(void (^)(CachedInstagramImage *))completionBlock {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([CachedInstagramImage class])
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
