//
//  MFTag.m
//  Obsidian
//
//  Created by Michaël Fortin on 2014-02-13.
//  Copyright (c) 2014 irradiated.net. All rights reserved.
//

#import "MFTag.h"
#import "NSException+FilesAdditions.h"
#import "NSColor+Additions.h"

@interface MFTag ()

@property (strong) NSString *name;
@property (strong) NSColor *color;
@property (strong) NSColor *darkerColor;
@property (assign) NSUInteger colorNumber;

@end

@implementation MFTag

- (id)init
{
	@throw [NSException exceptionWithReason:@"Use the designated initializer"];
}

- (id)initWithName:(NSString *)name colorNumber:(NSUInteger)colorNumber
{
    self = [super init];
    if (self)
    {
		NSMutableDictionary *colors = [NSMutableDictionary dictionary];
		colors[@(1)] = [NSColor colorWithCalibratedRed:0.78 green:0.78 blue:0.78 alpha:1];
		colors[@(2)] = [NSColor colorWithCalibratedRed:0.75 green:0.94 blue:0.15 alpha:1];
		colors[@(3)] = [NSColor colorWithCalibratedRed:0.92 green:0.71 blue:1 alpha:1];
		colors[@(4)] = [NSColor colorWithCalibratedRed:0.59 green:0.82 blue:1 alpha:1];
		colors[@(5)] = [NSColor colorWithCalibratedRed:1 green:0.94 blue:0.16 alpha:1];
		colors[@(6)] = [NSColor colorWithCalibratedRed:1 green:0.54 blue:0.54 alpha:1];
		colors[@(7)] = [NSColor colorWithCalibratedRed:1 green:0.78 blue:0.24 alpha:1];
		
        _name = name;
		_colorNumber = colorNumber;
		_color = colors[@(colorNumber)];
		_darkerColor = [_color darkerByPercent:0.2];
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"Tag \"%@\" (Color %lu)", self.name, (unsigned long)self.colorNumber];
}

@end
