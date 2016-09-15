//
//  MFFileTests.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-13.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "MFFileTests.h"
#import "MFTestEnvironmentHelpers.h"
#import "MFDirectory.h"
#import "MFFile.h"
#import "MFXMLValidator.h"
#import "MFNSCodingImplementer.h"

#define MFFileTestFilesFolderName @"MFDirectory+MFFile"

#pragma mark Unit tests for MFFile

@implementation MFFileTests

MFDirectory *_testDirectory;
MFFile *_file1_inFolderA;
MFFile *_file3_inFolderA;
MFFile *_nonExistingFile;
MFFile *_filePointingToDirectory;
MFFile *_imageFile;

#pragma mark SetUp and TearDown

- (void)setUp
{
	_testDirectory = [[MFTestEnvironmentHelpers testDirectory] subdirectory:MFFileTestFilesFolderName];
	_file1_inFolderA = [[_testDirectory subdirectory:@"Folder A"] file:@"File 1"];
	_file3_inFolderA = [[_testDirectory subdirectory:@"Folder A"] file:@"File 3"];
	_nonExistingFile = [MFFile fileWithPath:@"/Users/Blah.jpg"];
	_filePointingToDirectory = [MFFile fileWithPath:@"/Applications"];
	_imageFile = [_testDirectory file:@"image.jpg"];
	
	[MFTestEnvironmentHelpers cleanupAndCopyTestFilesToTestDirectoryFromBundleResources];
}

#pragma mark Creation tests

- (void)testCanCreateFileWithFileURL
{
	NSURL *fileURL = [NSURL fileURLWithPath:@"/Applications/iTunes.app/Contents/MacOS/iTunes"];
	MFFile *file = [MFFile fileWithFileURL:fileURL];
	XCTAssertNotNil(file);
	XCTAssertEqualObjects([file path], @"/Applications/iTunes.app/Contents/MacOS/iTunes");
}

#pragma mark Lifetime tests

- (void)testCantCreateFileFromPathWithTrailingSlash
{
	MFFile *file = [MFFile fileWithPath:@"/Applications/SomeFileButWithATrailingSlash/"];
	XCTAssertNil(file, @"File should not be initializable with a path containing a trailing slash");
}

#pragma mark Information tests

- (void)testCanReturnValidFileURL
{
	NSURL *url = [[MFFile fileWithPath:@"/Applications/iTunes.app/Contents/MacOS/iTunes"] fileURL];
	XCTAssertTrue([url isFileURL]);
	assertThat([url description], containsString(@"file://"));
}

#pragma mark File Attributes tests

- (void)testCanObtainFileAttributes
{
	NSDictionary *attributes = [_imageFile attributes];
	XCTAssertNotNil(attributes, @"An attributes dictionary should be returned");
	XCTAssertTrue([attributes count] > 0, @"The attributes dictionary should contain at least one key-value pair");
	XCTAssertTrue([[attributes allKeys] containsObject:NSFileSize], @"The attributes dictionary should at least contain information about the file's size");
}

- (void)testCanObtainSize
{
	unsigned long long fileSize = [_imageFile size];
	XCTAssertTrue(fileSize != 0, @"A non-zero file size should be returned");
	XCTAssertEqual(fileSize, (unsigned long long)207490, @"Wrong file size reported");
}

- (void)testCanObtainCreationDate
{
	NSDate *date = [_imageFile creationDate];
	XCTAssertNotNil(date);
	XCTAssertTrue([date isKindOfClass:[NSDate class]]);
}

- (void)testCanObtainModificationDate
{
	NSDate *date = [_imageFile modificationDate];
	XCTAssertNotNil(date);
	XCTAssertTrue([date isKindOfClass:[NSDate class]]);
}

#pragma mark File System Attributes Tests

- (void)testCanObtainFileSystemAttributes
{
	NSDictionary *attributes = [_testDirectory fileSystemAttributes];
	XCTAssertNotNil(attributes);
	XCTAssertTrue([attributes count] > 0, @"At least one file system attribute should be present in the attributes dictionary");
}

- (void)testCanObtainFileSystemSize
{
	unsigned long long fileSystemSize = [_testDirectory fileSystemSize];
	XCTAssertTrue(fileSystemSize > 10485760, @"File system size should be at least larger than 10 GB!");
}

- (void)testCanObtainFileSystemFreeSize
{
	unsigned long long fileSystemSize = [_testDirectory fileSystemFreeSize];
	XCTAssertTrue(fileSystemSize > 0, @"File system free size can't be smaller or equal to zero");
}

#pragma mark On-Disk Inspection tests

- (void)testCanTellThatFileExists
{
	XCTAssertTrue([_file1_inFolderA exists]);
}

- (void)testCanTellThatFileDoesNotExist
{
	XCTAssertFalse([_nonExistingFile exists]);
}

- (void)testCanTellThatFileDoesNotExistIfPointingToADirectory
{
	XCTAssertFalse([_filePointingToDirectory exists]);
}

#pragma mark Operations tests

- (void)testCanCreateFileIfDoesntExist
{
	MFFile *file = [_testDirectory file:@"Folder A/File 50"];
	MFFile *result = [file create];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	BOOL exists = [manager fileExistsAtPath:[file absolutePath]];
	
	XCTAssertNotNil(result, @"No file returned from create");
	XCTAssertTrue(exists, @"File does not exist on disk after create");
}

- (void)testCreateCreatesIntermediaryDirectories
{
	MFFile *file = [_testDirectory file:@"Intermediate Folder/File 50"];
	MFFile *result = [file create];
	
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[file absolutePath]];
	
	XCTAssertNotNil(result, @"No file returned from create");
	XCTAssertTrue(exists, @"File does not exist on disk after create");
}

#pragma mark Copy tests

- (void)testThrowsIfTryingToCopyToSamePath
{
	MFFile *source = [_testDirectory file:@"Test 1"];
	MFFile *sameFile = [_testDirectory file:@"Test 1"];
	MFDirectory *sameDirectory = [_testDirectory subdirectory:@"Test 1"];
	
	XCTAssertThrows([source copyTo:sameFile]);
	XCTAssertThrows([source copyTo:sameDirectory]);
}

- (void)testCopyToWorks
{
	MFFile *destination = [_testDirectory file:@"CopyToWorks"];
	MFFile *newFile = [_file1_inFolderA copyTo:destination];
	
	BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[destination path]];
	
	XCTAssertTrue(exist, @"File should exist at the destination after copy");
	XCTAssertNotNil(newFile, @"copyTo: did not return an MFFile instance for the new file");
}

- (void)testCopyToDontOverwriteFailsWhenFileExists
{
	MFFile *destination = [_testDirectory file:@"Folder A/File 2"];
	MFFile *newFile = [_file1_inFolderA copyTo:destination overwrite:NO];
	
	BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[destination path]];
	
	XCTAssertTrue(exist, @"File should still exist at the destination");
	XCTAssertNil(newFile, @"Should return nil to indicate failure to copy file");
}

- (void)testCopyToOverwriteWorksWhenFileExists
{
	NSError *error = nil;
	
	MFFile *destination = [_testDirectory file:@"Folder A/File 2"];
	MFFile *newFile = [_file1_inFolderA copyTo:destination overwrite:YES error:&error];
	
	BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[destination path]];
	
	XCTAssertTrue(exist, @"File should exist at the destination after copy");
	XCTAssertNotNil(newFile, @"copyTo: did not return an MFFile instance for the new file");
}

- (void)testCopyToDirectoryWorks
{
	MFFile *copied = [_file1_inFolderA copyTo:[_testDirectory subdirectory:@"Folder B"]];
	MFFile *expected = [[_testDirectory subdirectory:@"Folder B"] file:@"File 1"];
	
	BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:[expected absolutePath]];
	
	XCTAssertTrue(exist, @"File should exist in destination directory");
	XCTAssertEqualObjects(copied, expected, @"An MFFile instance should be returned and point to newly copied file");
}

- (void)testCopyToPathThatDoesntExistWorks
{
	MFFile *copied = [_file1_inFolderA copyTo:[_testDirectory subdirectory:@"Folder J"]];
	MFDirectory *destinationDir = [_testDirectory subdirectory:@"Folder J"];
	MFFile *expected = [destinationDir file:@"File 1"];
	
	BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationDir absolutePath]];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[expected absolutePath]];
	
	XCTAssertTrue(directoryExists, @"Directory should have been created to copy file into it");
	XCTAssertTrue(fileExists, @"File should exist in destination directory");
	XCTAssertEqualObjects(copied, expected, @"An MFFile instance should be returned and point to newly copied file");
}

- (void)testCopyThrowsIfDestinationIsNil
{
	XCTAssertThrows([_file1_inFolderA copyTo:nil]);
}

- (void)testCopyCreatesIntermediaryDirectories
{
	MFDirectory *destinationDir = [_testDirectory subdirectory:@"Folder K/Folder J/Folder M"];
	MFFile *copied = [_file1_inFolderA copyTo:destinationDir];
	
	BOOL isDirectory;
	BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationDir absolutePath] isDirectory:&isDirectory];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[copied absolutePath]];
	
	XCTAssertTrue(directoryExists);
	XCTAssertTrue(isDirectory, @"Expected a directory");
	XCTAssertTrue(fileExists);
}

#pragma mark Move tests

- (void)testThrowsIfTryingToMoveToSamePath
{
	MFFile *source = [_testDirectory file:@"Test 1"];
	MFFile *sameFile = [_testDirectory file:@"Test 1"];
	MFDirectory *sameDirectory = [_testDirectory subdirectory:@"Test 1"];
	
	XCTAssertThrows([source moveTo:sameFile]);
	XCTAssertThrows([source moveTo:sameDirectory]);
}

- (void)testMoveToDirectorySucceeds
{
	MFFile *newFile = [_file1_inFolderA moveTo:[_testDirectory subdirectory:@"Folder B"]];
	MFFile *expected = [_testDirectory file:@"Folder B/File 1"];
	
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[_file1_inFolderA absolutePath]];
	BOOL newFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[expected absolutePath]];
	
	XCTAssertNotNil(newFile, @"Operation failed");
	XCTAssertEqualObjects(newFile, expected, @"Did not obtain correct path for moved file");
	XCTAssertTrue(newFileExists, @"New file was not found at expected path");
	XCTAssertFalse(oldFileExists, @"Old file still exists");
}

- (void)testMoveToFileSucceeds
{
	MFFile *destinationFile = [_testDirectory file:@"Superfile"];
	MFFile *newFile = [_file1_inFolderA moveTo:destinationFile];
	
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[_file1_inFolderA absolutePath]];
	BOOL newFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath]];
	
	XCTAssertNotNil(newFile, @"Operation failed");
	XCTAssertEqualObjects(newFile, destinationFile, @"Did not obtain correct path for moved file");
	XCTAssertTrue(newFileExists, @"New file was not found at expected path");
	XCTAssertFalse(oldFileExists, @"Old file still exists");
}

- (void)testMoveSucceedsIfDestinationIsDirectoryAndPointsToFileAndOverwriting
{
	MFDirectory *directoryPointingToFile = [_testDirectory subdirectory:@"Folder B/File 4"];
	MFFile *newFile = [_file1_inFolderA moveTo:directoryPointingToFile overwrite:YES];
	MFDirectory *expectedDirectory = [_testDirectory subdirectory:@"Folder B/File 4"];
	MFFile *expectedFile = [_testDirectory file:@"Folder B/File 4/File 1"];
	
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[_file1_inFolderA absolutePath]];
	
	BOOL expectedDirectoryIsDirectory;
	BOOL expectedDirectoryExists = [[NSFileManager defaultManager] fileExistsAtPath:[expectedDirectory absolutePath] isDirectory:&expectedDirectoryIsDirectory];
	
	BOOL expectedFileIsDirectory;
	BOOL expectedFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[expectedFile absolutePath] isDirectory:&expectedFileIsDirectory];
	
	XCTAssertNotNil(newFile, @"Operation failed");
	XCTAssertEqualObjects(newFile, expectedFile, @"Did not obtain correct path for moved file");
	XCTAssertTrue(expectedDirectoryExists, @"Expected directory was not found");
	XCTAssertTrue(expectedFileExists, @"Expected file was not found");
	XCTAssertFalse(oldFileExists, @"Old file still exists");
}

- (void)testMoveFailsIfDestinationExistsAndSpecifyingParentFolderAndNotOverwriting
{
	MFFile *newFile = [_file3_inFolderA moveTo:[_testDirectory subdirectory:@"Folder B"] overwrite:NO];
	MFFile *expected = [_testDirectory file:@"Folder B/File 3"];
	
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[_file3_inFolderA absolutePath]];
	BOOL newFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[expected absolutePath]];
	
	XCTAssertNil(newFile, @"File should be nil to indicate failure");
	XCTAssertTrue(newFileExists, @"Destination item should still exist");
	XCTAssertTrue(oldFileExists, @"Old file should still exist");
}

- (void)testMoveSucceedsIfDestinationExistsAndSpecifyingParentFolderAndOverwriting
{
	MFFile *newFile = [_file3_inFolderA moveTo:[_testDirectory subdirectory:@"Folder B"] overwrite:YES];
	MFFile *expected = [_testDirectory file:@"Folder B/File 3"];
	
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[_file3_inFolderA absolutePath]];
	BOOL newFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[expected absolutePath]];
	
	XCTAssertNotNil(newFile);
	XCTAssertTrue(newFileExists, @"Destination item should exist");
	XCTAssertFalse(oldFileExists, @"Old file should not exist anymore post-move");
}

- (void)testMoveFailsIfDestinationExistsAndSpecifyingFileAndNotOverwriting
{
	MFFile *destinationFile = [_testDirectory file:@"Folder B/File 4"];
	MFFile *newFile = [_file1_inFolderA moveTo:destinationFile overwrite:NO];
	
	BOOL oldFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[_file1_inFolderA absolutePath]];
	BOOL newFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath]];
	
	XCTAssertNil(newFile, @"File should be nil to indicate failure");
	XCTAssertTrue(newFileExists, @"Destination item should still exist");
	XCTAssertTrue(oldFileExists, @"Old file should still exist");
}

- (void)testMoveFailsIfDestinationExistsAndIsFileOnDiskButSpecifiedAsDirectoryAndNotOverwriting
{
	MFDirectory *directoryPointingToFile = [_testDirectory subdirectory:@"Folder B/File 4"];
	MFFile *newFile = [_file1_inFolderA moveTo:directoryPointingToFile overwrite:NO];
	
	BOOL isDirectory;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[directoryPointingToFile absolutePath] isDirectory:&isDirectory];
	
	XCTAssertNil(newFile, @"File should be nil to indicate failure");
	XCTAssertFalse(isDirectory, @"File pointed to by directory should still be a file");
	XCTAssertTrue(exists, @"File pointed to by directory should still exist");
}

- (void)testMoveFailsIfDestinationExistsAndIsDirectoryOnDiskButSpecifiedAsFileAndNotOverwriting
{
	MFFile *filePointingToDirectory = [_testDirectory file:@"Folder B"];
	MFFile *newFile = [_file1_inFolderA moveTo:filePointingToDirectory overwrite:NO];
	
	BOOL isStillADirectory;
	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[filePointingToDirectory absolutePath] isDirectory:&isStillADirectory];
	
	XCTAssertNil(newFile, @"File should be nil to indicate failure");
	XCTAssertTrue(isStillADirectory, @"Path is not a directory anymore");
	XCTAssertTrue(exists, @"Path does not exist anymore");
}

- (void)testMoveThrowsIfDestinationIsNil
{
	XCTAssertThrows([_file1_inFolderA moveTo:nil]);
}

- (void)testMoveCreatesIntermediaryDirectories
{
	MFDirectory *destinationDir = [_testDirectory subdirectory:@"Folder K/Folder J/Folder M"];
	MFFile *moved = [_file1_inFolderA moveTo:destinationDir];
	
	BOOL isDirectory;
	BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationDir absolutePath] isDirectory:&isDirectory];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[moved absolutePath]];
	
	XCTAssertTrue(directoryExists);
	XCTAssertTrue(isDirectory, @"Expected a directory");
	XCTAssertTrue(fileExists);
}

#pragma mark Tests for writeData: and readData

- (void)testCanWriteData
{
	MFFile *destinationFile = [_testDirectory file:@"writtenData.bin"];
	NSData *data = [NSData dataWithContentsOfFile:[_imageFile absolutePath]];
	BOOL success = [destinationFile writeData:data];
	
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath]];
	
#if TARGET_OS_IPHONE
	UIImage *image = [UIImage imageWithContentsOfFile:[destinationFile absolutePath]];
#else
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:[destinationFile absolutePath]];
#endif
	
	XCTAssertTrue(success);
	XCTAssertTrue(fileExists);
	XCTAssertNotNil(image, @"Image could not be loaded from written data");
}

- (void)testWriteFailsIfFileExistsAndNotOverwriting
{
	MFFile *destinationFile = [_testDirectory file:@"Folder A"];
	NSData *data = [NSData dataWithContentsOfFile:[_imageFile absolutePath]];
	
	BOOL success = [destinationFile writeData:data];
	
	BOOL isDirectory;
	BOOL directoryStillExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath] isDirectory:&isDirectory];
	
	XCTAssertFalse(success);
	XCTAssertTrue(directoryStillExists);
	XCTAssertTrue(isDirectory, @"Expected directory");
}

- (void)testWriteCanOverwriteExistingFile
{
	MFFile *destinationFile = [_testDirectory file:@"Folder A"];
	NSData *data = [NSData dataWithContentsOfFile:[_imageFile absolutePath]];
	BOOL success = [destinationFile writeData:data overwrite:YES];
	
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath] isDirectory:&isDirectory];
	
	XCTAssertTrue(success);
	XCTAssertTrue(fileExists);
	XCTAssertFalse(isDirectory, @"Expected a file");
}

- (void)testWriteCreatesIntermediaryDirectoriesWhenWritingToNonExistingPath
{
	MFFile *destinationFile = [_testDirectory file:@"Folder A/Subfolder J/SomeFile.jpg"];
	NSData *data = [NSData dataWithContentsOfFile:[_imageFile absolutePath]];
	BOOL success = [destinationFile writeData:data overwrite:YES];
	
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath] isDirectory:&isDirectory];
	
	XCTAssertTrue(success);
	XCTAssertTrue(fileExists);
	XCTAssertFalse(isDirectory, @"Expected a file");
}

- (void)testWriteThrowsWhenAskedToWriteNilData
{
	MFFile *destinationFile = [_testDirectory file:@"anotherimage.jpg"];
	XCTAssertThrows([destinationFile writeData:nil overwrite:YES]);
}

- (void)testWriteReturnsFalseAndOutputsErrorWhenWritingToExistingFileAndOverwriteIsDisabled
{
	NSError *error;
	
	MFFile *destinationFile = [_testDirectory file:@"Folder A"];
	NSData *data = [NSData dataWithContentsOfFile:[_imageFile absolutePath]];
	BOOL success = [destinationFile writeData:data overwrite:NO error:&error];
	
	BOOL isDirectory;
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[destinationFile absolutePath] isDirectory:&isDirectory];
	
	XCTAssertFalse(success);
	XCTAssertNotNil(error, @"An error should be returned");
	XCTAssertTrue(fileExists);
	XCTAssertTrue(isDirectory, @"Expected a directory");
}

- (void)testCanReadData
{
	NSData *data = [_imageFile readData];
	
#if TARGET_OS_IPHONE
	UIImage *image = [UIImage imageWithData:data];
#else
	NSImage *image = [[NSImage alloc] initWithData:data];
#endif
	
	XCTAssertNotNil(image, @"Image could not be loaded from written data");
}

- (void)testReadReturnsNilAndReturnsErrorWhenReadingNonExistingPath
{
	NSError *error;
	NSData *data = [[_testDirectory file:@"NonExistingFile"] readData:&error];
	
	XCTAssertNil(data);
	XCTAssertNotNil(error);
}

#pragma mark Tests for archive: and unarchive

- (void)testCanArchiveAndUnarchiveObjectThatImplementsNSCodingInBinaryFormat
{
	MFNSCodingImplementer *object = [[MFNSCodingImplementer alloc] init];
	object.number = 5;
	
	MFFile *file = [_testDirectory file:@"archive"];
	
	[file archive:object];
	
	id unarchivedObject = [file unarchive];
	
	XCTAssertNotNil(unarchivedObject, @"Unarchiving returned nil object");
	XCTAssertTrue([unarchivedObject isKindOfClass:[MFNSCodingImplementer class]], @"Wrong class for unarchived object");
}

- (void)testCanArchiveAndUnarchiveObjectThatImplementsNSCodingInXMLPlistFormat
{
	MFNSCodingImplementer *object = [[MFNSCodingImplementer alloc] init];
	object.number = 5;
	
	MFFile *file = [_testDirectory file:@"archive"];
	
	[file archiveAsXMLPlist:object];
	
	BOOL validXML = [MFXMLValidator validateXML:[file readString]];
	id unarchivedObject1 = [file unarchiveFromXMLPlist];
	id unarchivedObject2 = [file unarchive];
	
	XCTAssertTrue(validXML, @"XML Plist archive did not contain valid XML");
	XCTAssertNotNil(unarchivedObject1, @"Unarchiving returned nil object");
	XCTAssertTrue([unarchivedObject1 isKindOfClass:[MFNSCodingImplementer class]], @"Wrong class for unarchived object");
	XCTAssertNotNil(unarchivedObject2, @"Unarchiving returned nil object");
	XCTAssertTrue([unarchivedObject2 isKindOfClass:[MFNSCodingImplementer class]], @"Wrong class for unarchived object");
}

- (void)testReturnsNilAndOutputsErrorWhenUnarchivingNonExistingPath
{
	NSError *error;
	id unarchived = [[_testDirectory file:@"flabergast"] unarchive:&error];
	
	XCTAssertNil(unarchived);
	XCTAssertNotNil(error, @"Should return an error");
}

- (void)testReturnsNilAndOutputsErrorWhenUnarchivingAFileWhichIsNotAnArchivedObject
{
	NSError *error;
	id unarchived = [_imageFile unarchive:&error];
	
	XCTAssertNil(unarchived);
	XCTAssertNotNil(error, @"Should return an error");
}

#pragma mark Description tests

- (void)testDescriptionIsEqualToAbsolutePath
{
	MFFile *file = [_testDirectory file:@"Blah"];
	NSString *descriptionString = [NSString stringWithFormat:@"%@", file];
	
	assertThat([file description], equalTo([file absolutePath]));
	assertThat(descriptionString, equalTo([file absolutePath]));
}

@end