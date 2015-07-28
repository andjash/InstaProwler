//
//  CachedInstagramImage.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CachedInstagramImage : NSManagedObject

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSDate *dateSaved;

@end
