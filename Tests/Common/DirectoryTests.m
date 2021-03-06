//
//  DirectoryTests.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-13.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "Directory.h"
#import "DirectoryTests.h"
#import "File.h"
#import "NSException+FilesAdditions.h"
#import "TestEnvironmentHelpers.h"

#if TARGET_OS_IPHONE
#import "Directory+iOS.h"
#else
#import "Directory+macOS.h"
#endif

#define DirectoryTestFilesFolderName @"Directory+File"

@implementation DirectoryTests
{
	NSString *_pathOutsideHomeFolder;
	NSString *_pathInHomeFolderAbbreviated;
	NSString *_pathInHomeFolderAbsolute;
	NSString *_absoluteTestPath;
	Directory *_testDirectory;
	NSFileManager *_fileManager;
}

- (void)setUp
{
	_pathOutsideHomeFolder = @"/Library/Preferences";
	_pathInHomeFolderAbbreviated = @"~/Library/Preferences";
	_pathInHomeFolderAbsolute = [@"~/Library/Preferences" stringByStandardizingPath];
	
	_fileManager = [NSFileManager defaultManager];
	
	_testDirectory = [[TestEnvironmentHelpers testDirectory] subdirectory:DirectoryTestFilesFolderName];
	
	[TestEnvironmentHelpers cleanupAndCopyTestFilesToTestDirectoryFromBundleResources];
	
	// Create an empty directory (because empty directories cannot be tracked by Git thus we can't include one in our test files structure).
	NSString *emptyDirectory = [[_testDirectory absolutePath] stringByAppendingPathComponent:@"Folder C (Empty)"];
	[_fileManager createDirectoryAtPath:emptyDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

- (NSArray *)contentsAtPath:(NSString *)path
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	NSArray *contents = [manager contentsOfDirectoryAtPath:path error:&error];
	
	if (error)
	{
		NSString *reason = [NSString stringWithFormat:@"Helper could not obtain contents at specified path %@. Error: %@", path, error];
		@throw [NSException exceptionWithReason:@"%@", reason];
	}
	
	return contents;
}

- (NSDate *)modificationDateForFileAtPath:(NSString *)path
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	NSDictionary *attributes = [manager attributesOfItemAtPath:path error:&error];
	
	if (error)
	{
		NSString *reason = [NSString stringWithFormat:@"Helper could not obtain attributes at specified path %@. Error: %@", path, error];
		@throw [NSException exceptionWithReason:@"%@", reason];
	}
	
	return [attributes fileModificationDate];
}

#pragma mark Equality Tests

- (void)testCanTellIfDirectoriesAreEqual
{
	Directory *dirA = [Directory directoryWithPath:@"/Applications"];
	Directory *dirB = [Directory directoryWithPath:@"/Applications"];
	XCTAssertEqualObjects(dirA, dirB);
}

- (void)testCanTellIfDirectoriesAreEqualIfCreatedFromAbsoluteAndAbbreviatedPaths
{
	Directory *dirA = [Directory directoryWithPath:_pathInHomeFolderAbbreviated];
	Directory *dirB = [Directory directoryWithPath:_pathInHomeFolderAbsolute];
	XCTAssertEqualObjects(dirA, dirB);
}

- (void)testCanTellIfDirectoriesAreDifferent
{
	Directory *dirA = [Directory directoryWithPath:@"/Applications"];
	Directory *dirB = [Directory directoryWithPath:@"/SomeOtherDirectory"];
	XCTAssertFalse([dirA isEqual:dirB]);
}

- (void)testCanTellIfDirectoryAndFilePointingAtSamePathAreDifferent
{
	Directory *dir = [Directory directoryWithPath:@"/Applications"];
	File *file = [File fileWithPath:@"/Applications"];
	XCTAssertFalse([dir isEqual:file]);
}

- (void)testDirectoriesHaveSameHashWhenTheyHaveTheSameAbsolutePath
{
	NSString *absolutePath = [@"~/Desktop" stringByStandardizingPath];
	Directory *absoluteDir = [Directory directoryWithPath:absolutePath];
	Directory *abbreviatedDir = [Directory directoryWithPath:@"~/Desktop"];
	XCTAssertTrue([absoluteDir hash] == [abbreviatedDir hash]);
}

- (void)testPathsHaveDifferentHashWhenNotTheSameConcreteType
{
	NSString *path = @"~/Desktop";
	Directory *absoluteDir = [Directory directoryWithPath:path];
	File *abbreviatedDir = [File fileWithPath:path];
	XCTAssertFalse([absoluteDir hash] == [abbreviatedDir hash]);
}

#pragma mark Creation tests

- (void)testCanCreateDirectoryWithPathThatStartsWithRoot
{
	Directory *dir = [Directory directoryWithPath:@"/Something/Test"];
	XCTAssertEqualObjects([dir path], @"/Something/Test");
}

- (void)testCanCreateDirectoryWithPathThatStartsWithTildeAndSlash
{
	Directory *dir = [Directory directoryWithPath:@"~/Something/Test"];
	XCTAssertEqualObjects([dir path], @"~/Something/Test");
}

- (void)testCantCreateDirectoryWithPathThatDoesntStartWithRootOrTildeAndSlash
{
	XCTAssertThrows([Directory directoryWithPath:@"~Something/Test"]);
}

- (void)testCantCreateDirectoryWithPathThatContainsSuccessiveSlashes
{
	XCTAssertThrows([Directory directoryWithPath:@"~Something////Test"]);
}

- (void)testCantCreateDirectoryWithNilPath
{
	XCTAssertThrows([Directory directoryWithPath:nil]);
}

- (void)testCanCreateValidDirectoryWithTrailingSlash
{
	Directory *dir = [Directory directoryWithPath:@"/Library/Preferences/"];
	
    XCTAssertEqual([[dir pathComponents] count], 3);
	XCTAssertEqualObjects([dir name], @"Preferences");
	XCTAssertEqualObjects([dir path], @"/Library/Preferences");
	XCTAssertEqualObjects([dir absolutePath], @"/Library/Preferences");
}

#pragma mark Tests for description

- (void)testDescriptionContainsPath
{
    XCTAssert([[_testDirectory description] containsString:[_testDirectory absolutePath]]);
}

#pragma mark Tests for path and absolutePath

// Created as: /Library/Preferences
// path: /Library/Preferences
// absolutePath: /Library/Preferences

- (void)testReturnsCorrectPathWhenPathIsOutsideHomeFolderAndAskingForAbbreviatedPath
{
	Directory *dir = [Directory directoryWithPath:_pathOutsideHomeFolder];
	XCTAssertEqualObjects([dir path], _pathOutsideHomeFolder);
}

- (void)testReturnsCorrectPathWhenPathIsOutsideHomeFolderAndAskingForAbsolutePath
{
	Directory *dir = [Directory directoryWithPath:_pathOutsideHomeFolder];
	XCTAssertEqualObjects([dir absolutePath], _pathOutsideHomeFolder);
}

// Created as: ~/Library/Preferences
// path: ~/Library/Preferences
// absolutePath: /Users/[username]/Library/Preferences

- (void)testReturnsCorrectPathWhenPathIsInHomeFolderAndCreatedAsAbbreviatedAndAskingForAbbreviatedPath
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbbreviated];
	XCTAssertEqualObjects([dir path], _pathInHomeFolderAbbreviated);
}

- (void)testReturnsCorrectPathWhenPathIsInHomeFolderAndCreatedAsAbbreviatedAndAskingForAbsolutePath
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbbreviated];
	XCTAssertEqualObjects([dir absolutePath], _pathInHomeFolderAbsolute);
}

// Created as: /Users/[username]/Library/Preferences
// path: ~/Library/Preferences
// absolutePath: /Users/[username]/Library/Preferences

- (void)testReturnsCorrectPathWhenPathIsInHomeFolderAndCreatedAsAbsoluteAndAskingForAbbreviatedPath
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbsolute];
	XCTAssertEqualObjects([dir path], _pathInHomeFolderAbbreviated);
}

- (void)testReturnsCorrectPathWhenPathIsInHomeFolderAndCreatedAsAbsoluteAndAskingForAbsolutePath
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbsolute];
	XCTAssertEqualObjects([dir absolutePath], _pathInHomeFolderAbsolute);
}

#pragma mark Tests for pathComponents

- (void)testReturnsCorrectPathComponents
{
	Directory *dir = [Directory directoryWithPath:_pathOutsideHomeFolder];
	NSArray *components = [dir pathComponents];
	XCTAssertEqualObjects(components[0], @"/");
	XCTAssertEqualObjects(components[1], @"Library");
	XCTAssertEqualObjects(components[2], @"Preferences");
}

#if !TARGET_OS_IPHONE

- (void)testReturnsCorrectAbsolutePathComponentsWhenPathIsOutsideHomeFolder
{
	Directory *dir = [Directory directoryWithPath:_pathOutsideHomeFolder];
	NSArray *components = [dir absolutePathComponents];
	XCTAssertEqualObjects(components[0], @"/");
	XCTAssertEqualObjects(components[1], @"Library");
	XCTAssertEqualObjects(components[2], @"Preferences");
}

// Created as: ~/Library/Preferences
// path: ~/Library/Preferences
// absolutePath: /Users/[username]/Library/Preferences

- (void)testReturnsCorrectPathComponentsWhenPathIsInHomeFolderAndCreatedAsAbbreviated
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbbreviated];
	NSArray *components = [dir pathComponents];
	XCTAssertEqualObjects(components[0], @"~");
	XCTAssertEqualObjects(components[1], @"Library");
	XCTAssertEqualObjects(components[2], @"Preferences");
}

- (void)testReturnsCorrectAbsolutePathComponentsWhenPathIsInHomeFolderAndCreatedAsAbbreviated
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbbreviated];
	NSArray *components = [dir absolutePathComponents];
	XCTAssertEqualObjects(components[0], @"/");
	XCTAssertEqualObjects(components[1], @"Users");
	XCTAssertEqualObjects(components[3], @"Library");
	XCTAssertEqualObjects(components[4], @"Preferences");
}

// Created as: /Users/[username]/Library/Preferences
// path: ~/Library/Preferences
// absolutePath: /Users/[username]/Library/Preferences

- (void)testReturnsCorrectPathComponentsWhenPathIsInHomeFolderAndCreatedAsAbsolute
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbsolute];
	NSArray *components = [dir pathComponents];
	XCTAssertEqualObjects(components[0], @"~");
	XCTAssertEqualObjects(components[1], @"Library");
	XCTAssertEqualObjects(components[2], @"Preferences");
}

- (void)testReturnsCorrectAbsolutePathComponentsWhenPathIsInHomeFolderAndCreatedAsAbsolute
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbsolute];
	NSArray *components = [dir absolutePathComponents];
	XCTAssertEqualObjects(components[0], @"/");
	XCTAssertEqualObjects(components[1], @"Users");
	XCTAssertEqualObjects(components[3], @"Library");
	XCTAssertEqualObjects(components[4], @"Preferences");
}

#endif

#pragma mark Tests for fileURL

- (void)testReturnsCorrectFileURLFromAbsolutePath
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbsolute];
	NSURL *fileURL = [dir fileURL];
	XCTAssertTrue([fileURL isFileURL], @"Not a file URL!");
	XCTAssertEqualObjects(fileURL, [NSURL fileURLWithPath:_pathInHomeFolderAbsolute]);
}

- (void)testReturnsCorrectFileURLFromAbbreviatedPath
{
	Directory *dir = [Directory directoryWithPath:_pathInHomeFolderAbbreviated];
	NSURL *fileURL = [dir fileURL];
	XCTAssertTrue([fileURL isFileURL], @"Not a file URL!");
	XCTAssertEqualObjects(fileURL, [NSURL fileURLWithPath:_pathInHomeFolderAbsolute]);
}

#pragma mark Tests for name and nameWithoutExtension

- (void)testReturnsCorrectNameWithoutExtensionInPath
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory"];
	XCTAssertTrue([[dir name] isEqualToString:@"SomeDirectory"], @"Wrong directory name returned");
}

- (void)testReturnsCorrectNameWithExtensionInPath
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory.app"];
	XCTAssertTrue([[dir name] isEqualToString:@"SomeDirectory.app"], @"Wrong directory name returned");
}

- (void)testReturnsCorrectNameWithoutExtensionWhenThereIsNoExtensionInThePath
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory"];
	XCTAssertTrue([[dir nameWithoutExtension] isEqualToString:@"SomeDirectory"]);
}

- (void)testReturnsCorrectNameWithoutExtensionWhenThereIsAnExtensionInThePath
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory.app"];
	XCTAssertTrue([[dir nameWithoutExtension] isEqualToString:@"SomeDirectory"]);
}

#pragma mark Tests for extension

- (void)testReturnsNilWhereThereIsNoExtension
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory"];
	XCTAssertTrue([dir extension] == nil, @"Should return nil when there is no extension");
}

- (void)testReturnsCorrectExtension
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory.app"];
	XCTAssertTrue([[dir extension] isEqualToString:@"app"]);
}

- (void)testReturnsLastExtensionIfMany
{
	Directory *dir = [Directory directoryWithPath:@"/Folder1/Folder2/SomeDirectory.test.app"];
	XCTAssertTrue([[dir extension] isEqualToString:@"app"], @"Should return the string after the last dot in the last path component");
}


#pragma mark Tests for UTI

#if !TARGET_OS_IPHONE
- (void)testReturnsCorrectUTIForFolder
{
	XCTAssertEqualObjects([_testDirectory type], @"public.folder");
}

- (void)testReturnsCorrectUTIForApplicationBundle
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app"];
	XCTAssertEqualObjects([dir type], @"com.apple.application-bundle");
}
#endif

#pragma mark Tests for icon

#if !TARGET_OS_IPHONE
- (void)testReturnsDirectoryIcon
{
	Directory *dir = [Directory directoryWithPath:@"/Applications"];
	NSImage *icon = [dir icon];
	XCTAssertNotNil(icon);
	XCTAssertTrue([icon size].width != 0 && [icon size].height != 0);
}
#endif

#pragma mark Tests for exists

- (void)testCanTellThatDirectoryExists
{
	Directory *dir = [Directory directoryWithPath:@"/Applications"];
	XCTAssertTrue([dir exists]);
}

- (void)testCanTellThatDirectoryDoesNotExist
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/Flagadah"];
	XCTAssertFalse([dir exists]);
}

- (void)testCanTellThatDirectoryDoesNotExistWhenPointingToAFile
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents/macOS/iTunes"];
	XCTAssertFalse([dir exists]);
}

#pragma mark Tests for itemExists

- (void)testCanTellThatItemExistsIfDirectory
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents/macOS"];
	XCTAssertTrue([dir itemExists]);
}

- (void)testCanTellThatItemExistsIfFile
{
	File *file = [File fileWithPath:@"/Applications/iTunes.app/Contents/macOS/iTunes"];
	XCTAssertTrue([file itemExists]);
}

- (void)testCanTellThatItemDoesNotExistAtPath
{
	Directory *dir = [Directory directoryWithPath:@"/Abracadabra"];
	XCTAssertFalse([dir exists]);
}

#pragma mark Tests for parent and subitem:

- (void)testCanReturnParentDirectory
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents"];
	XCTAssertEqualObjects([dir parent], [Directory directoryWithPath:@"/Applications/iTunes.app"]);
}

- (void)testReturnsNilWhenInRootAndAskedForParentDirectory
{
	Directory *dir = [Directory directoryWithPath:@"/"];
	XCTAssert([dir parent] == nil);
}

#if !TARGET_OS_IPHONE
- (void)testReturnsAbsoluteParentDirectoryWhenInPathCreatedWithTilde
{
	Directory *dir = [Directory directoryWithPath:@"~"];
	XCTAssertEqualObjects([dir parent], [Directory directoryWithPath:@"/Users"]);
}
#endif

- (void)testSubitemReturnsSubitemOfPathKind
{
	Path *path = [_testDirectory subitem:@"Subitem 1"];
	XCTAssertTrue([path isKindOfClass:[Path class]] && ![path isKindOfClass:[Directory class]]);
	XCTAssertEqualObjects([path absolutePath], [[_testDirectory absolutePath] stringByAppendingPathComponent:@"Subitem 1"]);
}

#pragma mark Tests for isFile and isDirectory

- (void)testIsFileWorks
{
	Directory *dirPointingToDirectory = [_testDirectory subdirectory:@"Folder A"];
	Directory *dirPointingToFile = [_testDirectory subdirectory:@"Folder A/File 1"];
	
	XCTAssertFalse([dirPointingToDirectory isFile]);
	XCTAssertTrue([dirPointingToFile isFile]);
}

- (void)testIsDirectoryWorks
{
	Directory *dirPointingToDirectory = [_testDirectory subdirectory:@"Folder A"];
	Directory *dirPointingToFile = [_testDirectory subdirectory:@"Folder A/File 1"];
	
	XCTAssertTrue([dirPointingToDirectory isDirectory]);
	XCTAssertFalse([dirPointingToFile isDirectory]);
}

#pragma mark Tests for delete and deleteContents

- (void)testCanDeleteIfPathExists
{
	Directory *dir = [_testDirectory subdirectory:@"Folder A"];
	XCTAssertTrue([dir delete], @"delete should report success");
	
	XCTAssertFalse([_fileManager fileExistsAtPath:[dir absolutePath]], @"Folder should not exist anymore");
}

- (void)testReportsDeletionSuccessIfPathDoesNotExist
{
	Directory *dir = [Directory directoryWithPath:@"/Abracadabra/SomeFolder"];
	XCTAssertTrue([dir delete]);
}

- (void)testCanDeleteContentsIfPathExists
{
	Directory *dir = [_testDirectory subdirectory:@"Folder B"];
	XCTAssertTrue([dir deleteContents], @"deleteContents should report success");
	
	NSArray *contents = [_fileManager contentsOfDirectoryAtPath:[dir absolutePath] error:nil];
	
	XCTAssertTrue([_fileManager fileExistsAtPath:[dir absolutePath]], @"Folder should still exist after deleting contents");
    XCTAssertTrue([contents count] == 0);
}

- (void)testCannotDeleteContentsIfPathDoesNotExistButDoesNotThrow
{
	Directory *dir = [Directory directoryWithPath:@"/Abracadabra/SomeFolder"];
	XCTAssertFalse([dir deleteContents]);
}

#if !TARGET_OS_IPHONE

- (void)testCanMoveToTrashIfPathExists
{
	Directory *dir = [_testDirectory subdirectory:@"Folder B"];
	Directory *dirInTrash = [[Directory trash] subdirectory:@"Folder B"];
	
	XCTAssertTrue([dir moveToTrash], @"moveToTrash should report success");
	XCTAssertFalse([_fileManager fileExistsAtPath:[dir absolutePath]], @"Folder should not exist at original path anymore");
	XCTAssertTrue([_fileManager fileExistsAtPath:[dirInTrash absolutePath]], @"Folder should be present in Trash");
}

- (void)testCannotMoveToTrashIfPathDoesNotExistButDoesNotThrow
{
	Directory *dir = [Directory directoryWithPath:@"/Abracadabra/SomeFolder"];
	XCTAssertFalse([dir moveToTrash]);
}

#endif

#pragma mark Tests for Directory creation

- (void)testCanCreateDirectoryFromFileURL
{
	NSString *originalPath = @"/Applications/Utilities";
	NSURL *url = [NSURL fileURLWithPath:originalPath];
	Directory *dir = [Directory directoryWithFileURL:url];
	XCTAssertEqualObjects([dir absolutePath], originalPath);
}

#pragma mark Tests for isEmpty

- (void)testCanTellThatDirectoryIsEmpty
{
	Directory *dir = [_testDirectory subdirectory:@"Folder C (Empty)"];
	XCTAssertTrue([dir isEmpty]);
}

- (void)testCanTellThatDirectoryIsNotEmpty
{
	Directory *dir = [Directory directoryWithPath:@"/Applications"];
	XCTAssertFalse([dir isEmpty]);
}

- (void)testIsEmptyReturnsNoIfPathIsNotADirectory
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents/macOS/iTunes"];
	XCTAssertFalse([dir isEmpty]);
}

#pragma mark Tests for isApplicationBundle

#if !TARGET_OS_IPHONE
- (void)testCanTellIfDirectoryIsAnApplicationBundle
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app"];
	XCTAssertTrue([dir isApplicationBundle]);
}
#endif

#pragma mark Tests for isBundle

#if !TARGET_OS_IPHONE
- (void)testCanTellIfDirectoryIsABundle
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app"];
	XCTAssertTrue([dir isBundle]);
}
#endif

#pragma mark Tests for items

- (void)testReturnsEmptyArrayIfDirectoryIsEmptyWhenAksingForItems
{
	Directory *dir = [_testDirectory subdirectory:@"Folder C (Empty)"];
	NSArray *items = [dir items];
	
    XCTAssertNotNil(items);
    XCTAssertTrue([items count] == 0);
}

- (void)testReturnsNilIfPathIsNotADirectoryWhenAksingForItems
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents/macOS/iTunes"];
	XCTAssertNil([dir items], @"Should return nil when asking for items and not a directory");
}

- (void)testReturnsCorrectInstancesOfDirectoryAndFileForDirectoryContents
{
	Directory *dir = [_testDirectory subdirectory:@"Folder B"];
	NSArray *items = [dir items];
	
    XCTAssertNotNil(items);
	XCTAssertTrue([items count] == 4);
    XCTAssertTrue([items[0] isKindOfClass:[File class]]);
	XCTAssertEqualObjects([items[0] name], @"File 3");
	XCTAssertTrue([items[1] isKindOfClass:[File class]]);
	XCTAssertEqualObjects([items[1] name], @"File 4");
    XCTAssertTrue([items[2] isKindOfClass:[File class]]);
	XCTAssertEqualObjects([items[2] name], @"File 5");
    XCTAssertTrue([items[3] isKindOfClass:[Directory class]]);
	XCTAssertEqualObjects([items[3] name], @"Subfolder 1");
}

#pragma mark Tests for files

- (void)testReturnsEmptyArrayIfDirectoryIsEmptyWhenAksingForFiles
{
	Directory *dir = [_testDirectory subdirectory:@"Folder C (Empty)"];
	NSArray *items = [dir files];
	
    XCTAssertNotNil(items);
	XCTAssertTrue([items count] == 0);
}

- (void)testReturnsNilIfPathIsNotADirectoryWhenAksingForFiles
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents/macOS/iTunes"];
	XCTAssertNil([dir files], @"Should return nil when asking for files and not a directory");
}

- (void)testReturnsCorrectInstancesOfFileWhenAskingForFiles
{
	Directory *dir = [_testDirectory subdirectory:@"Folder B"];
	NSArray *items = [dir files];
	
    XCTAssertNotNil(items);
	XCTAssertTrue([items count] == 3);
    XCTAssertTrue([items[0] isKindOfClass:[File class]]);
	XCTAssertEqualObjects([items[0] name], @"File 3");
	XCTAssertTrue([items[1] isKindOfClass:[File class]]);
	XCTAssertEqualObjects([items[1] name], @"File 4");
	XCTAssertTrue([items[2] isKindOfClass:[File class]]);
	XCTAssertEqualObjects([items[2] name], @"File 5");
}

#pragma mark Tests for subdirectories

- (void)testReturnsEmptyArrayIfDirectoryIsEmptyWhenAksingForSubdirectories
{
	Directory *dir = [_testDirectory subdirectory:@"Folder C (Empty)"];
	NSArray *items = [dir subdirectories];
	
    XCTAssertNotNil(items);
	XCTAssertTrue([items count] == 0);
}

- (void)testReturnsNilIfPathIsNotADirectoryWhenAksingForSubdirectories
{
	Directory *dir = [Directory directoryWithPath:@"/Applications/iTunes.app/Contents/macOS/iTunes"];
	XCTAssertNil([dir subdirectories], @"Should return nil when asking for subdirectories and not a directory");
}

- (void)testReturnsCorrectInstancesOfDirectoryWhenAskingForSubdirectories
{
	Directory *dir = [_testDirectory subdirectory:@"Folder B"];
	NSArray *items = [dir subdirectories];
	
    XCTAssertNotNil(items);
	XCTAssertTrue([items count] == 1);
    XCTAssertTrue([items[0] isKindOfClass:[Directory class]]);
	XCTAssertEqualObjects([items[0] name], @"Subfolder 1");
}

#pragma mark Tests for subdirectory: and file:

- (void)testCanCreateNewInstanceByAppendingSubdirectoryNamePathComponent
{
	Directory *directory = [Directory directoryWithPath:@"/"];
	Directory *subdirectory = [directory subdirectory:@"Applications"];
	XCTAssertEqualObjects([subdirectory absolutePath], @"/Applications");
	XCTAssertEqualObjects([subdirectory absolutePathComponents][0], @"/");
	XCTAssertEqualObjects([subdirectory absolutePathComponents][1], @"Applications");
}

- (void)testCanCreateNewInstanceByAppendingFileNamePathComponent
{
	Directory *directory = [Directory directoryWithPath:@"~/Desktop"];
	File *file = [directory file:@"SomeFile.jpg"];
	XCTAssertEqualObjects([file path], @"~/Desktop/SomeFile.jpg");
	XCTAssertEqualObjects([file pathComponents][0], @"~");
	XCTAssertEqualObjects([file pathComponents][1], @"Desktop");
	XCTAssertEqualObjects([file pathComponents][2], @"SomeFile.jpg");
}

#pragma mark Tests for create and createAndOverwrite:

- (void)testCanCreateDirectoryIfPathDoesntExist
{
	Directory *dir = [_testDirectory subdirectory:@"Folder Z"];
	Directory *returnedDir = [dir create];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	BOOL exists = [manager fileExistsAtPath:[dir absolutePath] isDirectory:&isDirectory];
	
	XCTAssertTrue(exists, @"Directory should have been created");
	XCTAssertTrue(isDirectory, @"Path should be a directory");
	XCTAssertEqualObjects(returnedDir, dir, @"Create should return an equal directory for call chaining");
}

- (void)testDoesntRemoveDirectoryContentAndSucceedsIfPathExistsAndIsDirectory
{
	Directory *dir = [_testDirectory subdirectory:@"Folder A"];
	NSArray *contentsBefore = [self contentsAtPath:[dir absolutePath]];
	Directory *returnedDir = [dir create];
	NSArray *contentsAfter = [self contentsAtPath:[dir absolutePath]];
	
	XCTAssertEqualObjects(contentsBefore, contentsAfter);
	XCTAssertEqualObjects(returnedDir, dir, @"Create should return an equal directory for call chaining");
}

- (void)testDoesntDeleteFileAndFailsAndReturnsNilIfPathExistsAndIsFile
{
	Directory *dir = [_testDirectory subdirectory:@"Folder A/File 1"];
	Directory *returnedDir = [dir create];
	
	BOOL isDirectory;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[dir absolutePath] isDirectory:&isDirectory];
	
	XCTAssertTrue(exists, @"File at the specified path should still exist");
	XCTAssertTrue(!isDirectory, @"File at the specified path should NOT be a directory");
    XCTAssertNil(returnedDir);
}

#pragma mark Tests for copyContentsTo: and copyContentsTo:andOverwrite:

- (void)testThrowsIfTryingToCopyContentsToSamePath
{
	Directory *sameDirectory = [Directory directoryWithPath:[_testDirectory absolutePath]];
	XCTAssertThrows([_testDirectory copyContentsTo:sameDirectory]);
}

- (void)testCopyContentsThrowsIfSourceIsNotADirectory
{
	Directory *source = [_testDirectory subdirectory:@"Folder A/File 1"];
	Directory *destination = [_testDirectory subdirectory:@"Folder C (Empty)"];
	Directory *result = [source copyContentsTo:destination];
	
	XCTAssertNil(result, @"Result should be nil because source is not a directory");
}

- (void)testCopyContentsReturnsNilIfOperationsRequiresOverwritingAndOverwriteIsDisabled
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder B (Copy)"];
	Directory *result1 = [source copyContentsTo:destination];
	Directory *result2 = [source copyContentsTo:destination overwrite:NO];
	XCTAssertNil(result1);
	XCTAssertNil(result2);
}

- (void)testCopyContentsCopiesContentRecursively
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder C (Empty)"];
	Directory *destinationSubdirectory = [destination subdirectory:@"Subfolder 1"];
	
	Directory *result = [source copyContentsTo:destination];
	NSArray *sourceContents = [self contentsAtPath:[source absolutePath]];
	NSArray *destinationContents = [self contentsAtPath:[destination absolutePath]];
	NSArray *destinationSubdirectoryContents = [self contentsAtPath:[destinationSubdirectory absolutePath]];
	
	XCTAssertEqualObjects(destinationContents, sourceContents);
	XCTAssertTrue([destinationSubdirectoryContents count] == 2);
    XCTAssertTrue([destinationSubdirectoryContents containsObject:@"File 6"]);
    XCTAssertTrue([destinationSubdirectoryContents containsObject:@"File 7"]);
	XCTAssertEqualObjects(result, destination);
}

- (void)testCopyContentsCreatesDestinationDirectoryIfItDoesntExist
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder Z"];
	Directory *result = [source copyContentsTo:destination];
	
	NSArray *sourceContents = [self contentsAtPath:[source absolutePath]];
	NSArray *destinationContents = [self contentsAtPath:[destination absolutePath]];
	
	XCTAssertEqualObjects(destinationContents, sourceContents);
	XCTAssertEqualObjects(result, destination);
}

- (void)testCopyContentsCanOverwriteExistingFiles
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder B (Copy)"];
	Directory *result = [source copyContentsTo:destination overwrite:YES];
	
	File *sourceFile1 = [source file:@"File 4"];
	Directory *sourceSubfolder1 = [source subdirectory:@"Subfolder 1"];
	NSDate *sourceFile1ModificationDate = [self modificationDateForFileAtPath:[sourceFile1 absolutePath]];
	NSDate *sourceSubfolderModificationDate = [self modificationDateForFileAtPath:[sourceSubfolder1 absolutePath]];
	
	File *overwrittenFile1 = [destination file:@"File 4"];
	Directory *overwrittenSubfolder1 = [destination subdirectory:@"Subfolder 1"];
	NSDate *overwrittenFile1ModificationDate = [self modificationDateForFileAtPath:[overwrittenFile1 absolutePath]];
	NSDate *overwrittenSubfolderModificationDate = [self modificationDateForFileAtPath:[overwrittenSubfolder1 absolutePath]];
	
	XCTAssertNotNil(result, @"Failed to overwrite existing files?");
	XCTAssertEqualObjects(overwrittenFile1ModificationDate, sourceFile1ModificationDate);
	XCTAssertEqualObjects(overwrittenSubfolderModificationDate, sourceSubfolderModificationDate);
}

- (void)testCopyContentsToFailsIfDestinationIsNil
{
	XCTAssertThrows([_testDirectory copyContentsTo:nil]);
}

- (void)testCopyCreatesIntermediaryDirectories
{
	Directory *destinationDir = [_testDirectory subdirectory:@"Folder K/Folder J/Folder M"];
	Directory *copied = [[_testDirectory subdirectory:@"Folder A"] copyTo:destinationDir];
	
	BOOL isDirectory;
	BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationDir absolutePath] isDirectory:&isDirectory];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[[destinationDir file:@"File 1"] absolutePath]];
	
	XCTAssertNotNil(copied);
	XCTAssertTrue(directoryExists);
	XCTAssertTrue(isDirectory, @"Expected a directory");
	XCTAssertTrue(fileExists);
}

#pragma mark Tests for copyTo: and copyTo:andOverwrite:

- (void)testThrowsIfTryingToCopyToSamePath
{
	Directory *sameDirectory = [Directory directoryWithPath:[_testDirectory absolutePath]];
	XCTAssertThrows([_testDirectory copyTo:sameDirectory]);
}

- (void)testCopyToFailsIfDestinationDirectoryExists
{
	NSError *error;
	
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder C (Empty)"];
	Directory *result = [source copyTo:destination overwrite:NO error:&error];
	
	XCTAssertNotNil(error);
	XCTAssertNil(result);
}

- (void)testCopyToFailsIfDestinationDirectoryPointsToFile
{
	NSError *error;
	
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder B (Copy)/File 4"];
	Directory *result = [source copyTo:destination overwrite:NO error:&error];
	
	XCTAssertNotNil(error);
	XCTAssertNotNil([error description]);
	XCTAssertNil(result);
}

- (void)testCopyToSucceedsIfDestinationDirectoryExistsAndOverwriting
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder C (Empty)"];
	Directory *result = [source copyTo:destination overwrite:YES];
	
	XCTAssertNotNil(result);
	NSArray *sourceContents = [self contentsAtPath:[source absolutePath]];
	NSArray *destinationContents = [self contentsAtPath:[destination absolutePath]];
	XCTAssertEqualObjects(destinationContents, sourceContents);
}

- (void)testCopyToSucceedsIfDestinationDirectoryExistsAndPointsToFileAndOverwriting
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder B (Copy)/File 4"];
	Directory *result = [source copyTo:destination overwrite:YES];
	
	XCTAssertNotNil(result);
	NSArray *sourceContents = [self contentsAtPath:[source absolutePath]];
	NSArray *destinationContents = [self contentsAtPath:[destination absolutePath]];
	XCTAssertEqualObjects(destinationContents, sourceContents);
}

- (void)testCopyToReturnsDirectoryIfSucceedsWithoutOverwrite
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder Z"];
	Directory *result = [source copyTo:destination];
	
	XCTAssertNotNil(result);
	XCTAssertEqualObjects(result, destination);
}

- (void)testCopyToThrowsIfDestinationIsNil
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	XCTAssertThrows([source copyTo:nil overwrite:YES error:nil]);
}

#pragma mark Tests for moveTo: and moveTo:andOverwrite:

- (void)testThrowsIfTryingToMoveToSamePath
{
	Directory *sameDirectory = [Directory directoryWithPath:[_testDirectory absolutePath]];
	XCTAssertThrows([_testDirectory moveTo:sameDirectory]);
}

- (void)testMoveToFailsIfDestinationDirectoryPointsToFile
{
	NSError *error;
	
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder B (Copy)/File 4"];
	Directory *result = [source moveTo:destination overwrite:NO error:&error];
	
	XCTAssertNotNil(error);
	XCTAssertNotNil([error description]);
	XCTAssertNil(result);
}

- (void)testMoveToSucceedsIfDestinationDirectoryExistsAndOverwriting
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder C (Empty)"];
	NSArray *sourceContents = [self contentsAtPath:[source absolutePath]];
	Directory *result = [source moveTo:destination overwrite:YES];
	NSArray *destinationContents = [self contentsAtPath:[destination absolutePath]];
	
	XCTAssertNotNil(result);
	XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[source absolutePath]], @"Source not removed");
	XCTAssertEqualObjects(destinationContents, sourceContents);
}

- (void)testMoveToSucceedsIfDestinationDirectoryExistsAndPointsToFileAndOverwriting
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder B (Copy)/File 4"];
	NSArray *sourceContents = [self contentsAtPath:[source absolutePath]];
	Directory *result = [source moveTo:destination overwrite:YES];
	NSArray *destinationContents = [self contentsAtPath:[destination absolutePath]];
	
	XCTAssertNotNil(result);
	XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[source absolutePath]], @"Source not removed");
	XCTAssertEqualObjects(destinationContents, sourceContents);
}

- (void)testMoveToReturnsDirectoryIfSucceedsWithoutOverwrite
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	Directory *destination = [_testDirectory subdirectory:@"Folder Z"];
	Directory *result = [source moveTo:destination];
	
	XCTAssertNotNil(result);
	XCTAssertEqualObjects(result, destination);
}

- (void)testMoveToFailsIfDestinationIsNil
{
	Directory *source = [_testDirectory subdirectory:@"Folder B"];
	XCTAssertThrows([source moveTo:nil overwrite:YES error:nil]);
}

- (void)testMoveCreatesIntermediaryDirectories
{
	Directory *destinationDir = [_testDirectory subdirectory:@"Folder K/Folder J/Folder M"];
	Directory *moved = [[_testDirectory subdirectory:@"Folder A"] moveTo:destinationDir];
	
	BOOL isDirectory;
	BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationDir absolutePath] isDirectory:&isDirectory];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[[destinationDir file:@"File 1"] absolutePath]];
	
	XCTAssertNotNil(moved);
	XCTAssertTrue(directoryExists);
	XCTAssertTrue(isDirectory, @"Expected a directory");
	XCTAssertTrue(fileExists);
}

#pragma mark Description tests

- (void)testDescriptionIsEqualToAbsolutePath
{
	Directory *directory = [_testDirectory subdirectory:@"Folder B"];
	NSString *descriptionString = [NSString stringWithFormat:@"%@", directory];
	
	XCTAssertEqualObjects([directory description], [directory absolutePath]);
	XCTAssertEqualObjects(descriptionString, [directory absolutePath]);
}

@end
