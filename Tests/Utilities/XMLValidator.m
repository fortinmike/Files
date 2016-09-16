//
//  XMLValidator.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-05-15.
//  Copyright (c) 2013 Michaël Fortin. All rights reserved.
//

#import "XMLValidator.h"

@implementation XMLValidator

+ (BOOL)validateXML:(NSString *)xml
{
	NSData *data = [xml dataUsingEncoding:NSUTF8StringEncoding];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	return [parser parse];
}

@end
