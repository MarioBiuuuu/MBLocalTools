/*******************************************************************************
 Copyright © 2019 Adrian. All rights reserved.
 
 File name:     MBLocalizableTools.h
 Author:        Adrian
 
 Project name:  GPLocalTools
 
 Description:
 
 
 History:
 2019/5/8: File created.
 
 ********************************************************************************/

#import <Foundation/Foundation.h>

@class MBLocalizableTools;

@protocol MBLocalizableToolsDelegate <NSObject>

- (void)localizableToolsEndParse:(MBLocalizableTools *)tool;
- (void)localizableToolsEndWrite:(MBLocalizableTools *)tool;
- (void)localizableToolsError:(MBLocalizableTools *)tool error:(NSError *)error;

@end

@interface MBLocalizableTools : NSObject
/** 协议 */
@property (nonatomic, assign) id<MBLocalizableToolsDelegate> delegate;


/** 解析完成后，文件被存放的路径 */
@property (nonatomic, strong, readonly) NSArray *languagePaths;


/**
 初始化

 @param filePath 各国语言文件路径（必须为 csv 文件）
 @param lanCount 语言数
 @return MBLocalizableTools
 */
- (instancetype)initWithSourceFilePath:(NSString *)filePath savePath:(NSString *)savePath languageCount:(NSUInteger)lanCount;

/**
 初始化
 
 @param fileName 各国语言文件名（必须为 csv 文件）
 @param lanCount 语言数
 @return MBLocalizableTools
 */
- (instancetype)initWithSourceFileName:(NSString *)fileName savePath:(NSString *)savePath languageCount:(NSUInteger)lanCount;


/**
 解析调用这个方法
 */
- (void)beginParse;

@end
