/*******************************************************************************
 Copyright © 2019 Adrian. All rights reserved.
 
 File name:     MBLocalizableTools.m
 Author:        Adrian
 
 Project name:  GPLocalTools
 
 Description:
 
 
 History:
 2019/5/8: File created.
 
 ********************************************************************************/

#import "MBLocalizableTools.h"
#import "CHCSVParser.h"

@interface MBLocalizableTools () <CHCSVParserDelegate>

@property (nonatomic, strong) NSArray<NSMutableArray *> *paeseResults;
@property (nonatomic, strong) CHCSVParser *csvParser;
@property (nonatomic, assign) NSUInteger lanCount;
@property (nonatomic, strong) NSMutableArray *keys;

@property (nonatomic, strong, readwrite) NSArray *languagePaths;
@property (nonatomic, copy) NSString *saveLocalizableRootFilePath;
@end

@implementation MBLocalizableTools

#pragma mark - Init
- (instancetype)initWithSourceFilePath:(NSString *)filePath savePath:(NSString *)savePath languageCount:(NSUInteger)lanCount {
    self = [super init];
    if (self) {
        _lanCount = lanCount;
        _saveLocalizableRootFilePath = savePath;
        CHCSVParser *parse = [[CHCSVParser alloc] initWithContentsOfCSVURL:[NSURL fileURLWithPath:filePath]];
        parse.delegate = self;
        _csvParser = parse;
        
    }
    return self;
}

- (instancetype)initWithSourceFileName:(NSString *)fileName savePath:(NSString *)savePath languageCount:(NSUInteger)lanCount {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:(fileName.pathExtension.length > 0) ? nil : @"csv"];
    return [self initWithSourceFilePath:filePath savePath:savePath languageCount:lanCount];
}

- (void)setUpdata {
    _keys = [NSMutableArray array];
    
    NSMutableArray *temp = [NSMutableArray array];
    for (NSUInteger i = 0; i < _lanCount; i++) {
        [temp addObject:[NSMutableArray array]];
    }
    _paeseResults = [temp copy];
}

#pragma Puablic
- (void)beginParse {
    [self setUpdata];
    [_csvParser parse];
}

#pragma mark - CHCSVParserDelegate
- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    NSLog(@"ParserDidBeginDocument");
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(localizableToolsError:error:)]) {
        [self.delegate localizableToolsError:self error:error];
    }
    NSLog(@"Parser error: %@", error);
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSLog(@"ParserDidEndDocument");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(localizableToolsEndParse:)]) {
        [self.delegate localizableToolsEndParse:self];
    }
    
    @autoreleasepool {
        NSMutableArray *languagePaths = [NSMutableArray array];
        
        NSString *rootPath = self.saveLocalizableRootFilePath;
        if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath isDirectory:nil]) {
            [[NSFileManager defaultManager] removeItemAtPath:rootPath error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSLog(@"CSV 文件被保存到：%@", rootPath);
        
        for (NSUInteger i = 0; i < _lanCount; i++) {
            
            NSArray *aLanguages = _paeseResults[i];
            NSMutableArray *temps = [NSMutableArray array];
            NSUInteger aLanCount = aLanguages.count;
            for (NSUInteger i = 0, max = _keys.count; i < max; i++) {
                if (i < aLanCount) {
                    // 避免文本中还有逗号
                    NSString *aLanguage = [self removeInvalidStr:aLanguages[i]];
                    [temps addObject:[NSString stringWithFormat:@"\"%@\"=\"%@\";",_keys[i], aLanguage]];
                } else {
                    [temps addObject:[NSString stringWithFormat:@"\"%@\"=\"%@\";",_keys[i], @""]];
                }
            }
            
            NSString *csvFile = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"language_%@.csv", @(i)]];
            [[NSFileManager defaultManager] createFileAtPath:csvFile contents:nil attributes:nil];
            [languagePaths addObject:csvFile];
            
            CHCSVWriter *writer = [[CHCSVWriter alloc] initForWritingToCSVFile:csvFile];
            for (NSUInteger i = 0, max = temps.count; i < max; i++) {
                [writer writeField:temps[i]];
                [writer finishLine];
            }
        }
        
        _languagePaths = [languagePaths copy];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(localizableToolsEndWrite:)]) {
            [self.delegate localizableToolsEndWrite:self];
        }
    }
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    field = field.length == 0 ? @"👻👻👻" : field;
    
    if (fieldIndex == 0) {        
        [_keys addObject:field];
    }
    
    if (fieldIndex < _paeseResults.count) {
        [_paeseResults[fieldIndex] addObject:field];
    }
}

#pragma mark - Helper
- (NSString *)removeInvalidStr:(NSString *)sourceStr {
    NSMutableString *aLanguage = [[NSMutableString alloc] initWithString:sourceStr];
    if ([aLanguage containsString:@","] && [aLanguage hasPrefix:@"\""] && [aLanguage hasSuffix:@"\""]) {
        [aLanguage replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
        [aLanguage deleteCharactersInRange:NSMakeRange(aLanguage.length-1, 1)];
    }
    return [aLanguage copy];
}

@end
