//
//  CachedInstagramPost.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 28/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedInstagramPost : NSManagedObject

@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * postJson;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSDate *postDate;
@property (nonatomic, strong) NSDate *savedDate;

@end
