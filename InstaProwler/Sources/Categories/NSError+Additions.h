//
//  NSError+Additions.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Additions)

//InstagramMediaItemsModel errors

extern NSInteger const kInstagramMediaItemsModelNoSuchUser;

//InstagramService errors

extern NSInteger const kInstagramServiceAccountIsPrivate;

@end
