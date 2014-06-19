//
//  EasyUnarchive.h
//  DemoForZipx
//
//  Created by Darklinden on 5/22/12.
//  Copyright (c) 2012 darklinden. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_autoDetectionThreshold          @"autoDetectionThreshold"
#define KEY_Decoded                         @"Decoded"
#define KEY_Encoding                        @"Encoding"

#define KEY_XADFileNameKey                  @"FileName"
#define KEY_XADCommentKey                   @"Comment"
#define KEY_XADFileSizeKey                  @"FileSize"
#define KEY_XADCompressedSizeKey            @"CompressedSize"
#define KEY_XADCompressionNameKey           @"CompressionName"

#define KEY_XADIsDirectoryKey               @"IsDirectory"
#define KEY_XADIsResourceForkKey            @"IsResourceFork"
#define KEY_XADIsArchiveKey                 @"IsArchive"
#define KEY_XADIsHiddenKey                  @"IsHidden"
#define KEY_XADIsLinkKey                    @"IsLink"
#define KEY_XADIsHardLinkKey                @"IsHardLink"
#define KEY_XADLinkDestinationKey           @"LinkDestination"
#define KEY_XADIsCharacterDeviceKey         @"IsCharacterDevice"
#define KEY_XADIsBlockDeviceKey             @"IsBlockDevice"
#define KEY_XADDeviceMajorKey               @"DeviceMajor"
#define KEY_XADDeviceMinorKey               @"DeviceMinor"
#define KEY_XADIsFIFOKey                    @"IsFIFO"
#define KEY_XADIsEncryptedKey               @"IsEncrypted"
#define KEY_XADIsCorruptedKey               @"IsCorrupted"

#define KEY_XADLastModificationDateKey      @"LastModificationDate"
#define KEY_XADLastAccessDateKey            @"LastAccessDate"
#define KEY_XADLastAttributeChangeDateKey   @"LastAttributeChangeDate"
#define KEY_XADCreationDateKey              @"CreationDate"
#define KEY_XADExtendedAttributesKey        @"ExtendedAttributes"
#define KEY_XADFileTypeKey                  @"FileType"
#define KEY_XADFileCreatorKey               @"FileCreator"
#define KEY_XADFinderFlagsKey               @"FinderFlags"
#define KEY_XADFinderInfoKey                @"FinderInfo"
#define KEY_XADPosixPermissionsKey          @"PosixPermissions"
#define KEY_XADPosixUserKey                 @"PosixUser"
#define KEY_XADPosixGroupKey                @"PosixGroup"
#define KEY_XADPosixUserNameKey             @"PosixUserName"
#define KEY_XADPosixGroupNameKey            @"PosixGroupName"
#define KEY_XADDOSFileAttributesKey         @"DOSFileAttributes"
#define KEY_XADWindowsFileAttributesKey     @"WindowsFileAttributes"
#define KEY_XADAmigaProtectionBitsKey       @"AmigaProtectionBits"

#define KEY_XADIndexKey                     @"Index"
#define KEY_XADDataOffsetKey                @"DataOffset"
#define KEY_XADDataLengthKey                @"DataLength"
#define KEY_XADSkipOffsetKey                @"SkipOffset"
#define KEY_XADSkipLengthKey                @"SkipLength"

#define KEY_XADIsSolidKey                   @"IsSolid"
#define KEY_XADFirstSolidIndexKey           @"FirstSolidIndex"
#define KEY_XADFirstSolidEntryKey           @"FirstSolidEntry"
#define KEY_XADNextSolidIndexKey            @"NextSolidIndex"
#define KEY_XADNextSolidEntryKey            @"NextSolidEntry"
#define KEY_XADSolidObjectKey               @"SolidObject"
#define KEY_XADSolidOffsetKey               @"SolidOffset"
#define KEY_XADSolidLengthKey               @"SolidLength"

#define KEY_XADArchiveNameKey               @"ArchiveName"
#define KEY_XADVolumesKey                   @"Volumes"
#define KEY_XADDiskLabelKey                 @"DiskLabel"
#define KEY_XADLastBackupDateKey            @"XADLastBackupDate"
#define KEY_XADVolumeScanningFailedKey      @"XADVolumeScanningFailed"


@protocol EasyUnarchiveDelegate <NSObject>
- (void)didParsedFileContents:(NSArray*)contents withError:(NSString *)err;
- (void)needPassword;
- (void)didFinishUnarchiveToFolder:(NSString *)folder withError:(NSString *)err;
- (void)needEncoding:(NSArray *)encodingArray;
@end

@interface EasyUnarchive : NSObject

+ (BOOL)isExecuting;
+ (BOOL)requestContentWithDelegate:(id)delegate file:(NSString *)filePath;
+ (BOOL)requestUnarchiveWithDelegate:(id)delegate file:(NSString *)filePath selectedFiles:(NSArray *)array;
+ (void)setPassword:(NSString*)apass;
+ (void)setEncoding:(NSNumber *)aencoding;
+ (void)cancel;

+ (NSString *)nameOfEncoding:(NSStringEncoding)encoding;

@end
