//
//  GBCommentsProcessor-PreprocessingTesting.m
//  appledoc
//
//  Created by Tomaz Kragelj on 14.2.11.
//  Copyright (C) 2011 Gentle Bytes. All rights reserved.
//

#import "GBApplicationSettingsProvider.h"
#import "GBDataObjects.h"
#import "GBStore.h"
#import "GBCommentsProcessor.h"

@interface GBCommentsProcessor (PrivateAPI)
- (NSString *)stringByPreprocessingString:(NSString *)string;
- (NSString *)stringByConvertingCrossReferencesInString:(NSString *)string;
@end

#pragma mark -

@interface GBCommentsProcessorPreprocessingTesting : GBObjectsAssertor

- (GBCommentsProcessor *)processorWithStore:(id)store;
- (GBCommentsProcessor *)processorWithStore:(id)store context:(id)context;

@end

#pragma mark -

@implementation GBCommentsProcessorPreprocessingTesting

#pragma mark Formatting markers conversion

- (void)testStringByPreprocessingString_shouldHandleBoldMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"*bold1* *bold text* * bolder text *"];
	NSString *result2 = [processor stringByPreprocessingString:@"*bold1* Middle *bold text*"];
	// verify
	assertThat(result1, is(@"**bold1** **bold text** ** bolder text **"));
	assertThat(result2, is(@"**bold1** Middle **bold text**"));
}

- (void)testStringByPreprocessingString_shouldHandleItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"_bold1_ _bold text_ _ bolder text _"];
	NSString *result2 = [processor stringByPreprocessingString:@"_bold1_ Middle _bold text_"];
	// verify
	assertThat(result1, is(@"_bold1_ _bold text_ _ bolder text _"));
	assertThat(result2, is(@"_bold1_ Middle _bold text_"));
}

- (void)testStringByPreprocessingString_shouldHandleBoldItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result = [processor stringByPreprocessingString:@"_*text1*_ *_marked text_* _* text2 *_"];
	// verify
	assertThat(result, is(@"***text1*** ***marked text*** *** text2 ***"));
}

- (void)testStringByPreprocessingString_shouldHandleMonospaceMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result = [processor stringByPreprocessingString:@"`mono` ` monoer `"];
	// verify
	assertThat(result, is(@"`mono` ` monoer `"));
}

- (void)testStringByPreprocessingString_shouldHandleMarkdownBoldMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"__text1__ __ marked __"];
	NSString *result2 = [processor stringByPreprocessingString:@"**text1** ** marked **"];
	// verify
	assertThat(result1, is(@"**text1** ** marked **"));
	assertThat(result2, is(@"**text1** ** marked **"));
}

- (void)testStringByPreprocessingString_shouldHandleMarkdownBoldItalicsMarkers {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByPreprocessingString:@"__*text1*__ __* marked *__"];
	NSString *result2 = [processor stringByPreprocessingString:@"_**text1**_ _** marked **_"];
	NSString *result3 = [processor stringByPreprocessingString:@"*__text1__* *__ marked __*"];
	NSString *result4 = [processor stringByPreprocessingString:@"**_text1_** **_ marked _**"];
	NSString *result5 = [processor stringByPreprocessingString:@"___text1___ ___ marked ___"];
	NSString *result6 = [processor stringByPreprocessingString:@"***text1*** *** marked ***"];
	// verify
	assertThat(result1, is(@"***text1*** *** marked ***"));
	assertThat(result2, is(@"***text1*** *** marked ***"));
	assertThat(result3, is(@"***text1*** *** marked ***"));
	assertThat(result4, is(@"***text1*** *** marked ***"));
	assertThat(result5, is(@"***text1*** *** marked ***"));
	assertThat(result6, is(@"***text1*** *** marked ***"));
}

#pragma mark Class, category and protocol cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClass {
	// setup
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBClassData classDataWithName:@"Class"], nil];
	GBCommentsProcessor *processor = [self processorWithStore:store];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Class"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Class>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Unknown"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<Unknown>"];
	// verify
	assertThat(result1, is(@"[Class](Classes/Class.html)"));
	assertThat(result2, is(@"[Class](Classes/Class.html)"));
	assertThat(result3, is(@"Unknown"));
	assertThat(result4, is(@"<Unknown>"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategory {
	// setup
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBCategoryData categoryDataWithName:@"Category" className:@"Class"], nil];
	GBCommentsProcessor *processor = [self processorWithStore:store];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Class(Category)"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Class(Category)>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Class(Unknown)"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<Class(Unknown)>"];
	// verify
	assertThat(result1, is(@"[Class(Category)](Categories/Class(Category).html)"));
	assertThat(result2, is(@"[Class(Category)](Categories/Class(Category).html)"));
	assertThat(result3, is(@"Class(Unknown)"));
	assertThat(result4, is(@"<Class(Unknown)>"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertProtocol {
	// setup
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:[GBProtocolData protocolDataWithName:@"Protocol"], nil];
	GBCommentsProcessor *processor = [self processorWithStore:store];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"Protocol"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<Protocol>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"Unknown"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<Unknown>"];
	// verify
	assertThat(result1, is(@"[Protocol](Protocols/Protocol.html)"));
	assertThat(result2, is(@"[Protocol](Protocols/Protocol.html)"));
	assertThat(result3, is(@"Unknown"));
	assertThat(result4, is(@"<Unknown>"));
}

#pragma mark Local members cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassLocalInstanceMethod {
	// setup
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	GBCommentsProcessor *processor = [self processorWithStore:store context:class];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"method:"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<method:>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-method:"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-method:>"];
	NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"another:"];
	NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"<another:>"];
	// verify
	assertThat(result1, is(@"[method:](#//api/name/method:)"));
	assertThat(result2, is(@"[method:](#//api/name/method:)"));
	assertThat(result3, is(@"[method:](#//api/name/method:)"));
	assertThat(result4, is(@"[method:](#//api/name/method:)"));
	assertThat(result5, is(@"another:"));
	assertThat(result6, is(@"<another:>"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassLocalClassMethod {
	// setup
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry classMethodWithNames:@"method", nil], nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	GBCommentsProcessor *processor = [self processorWithStore:store context:class];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"method:"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<method:>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"+method:"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<+method:>"];
	NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"another:"];
	NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"<another:>"];
	// verify
	assertThat(result1, is(@"[method:](#//api/name/method:)"));
	assertThat(result2, is(@"[method:](#//api/name/method:)"));
	assertThat(result3, is(@"[method:](#//api/name/method:)"));
	assertThat(result4, is(@"[method:](#//api/name/method:)"));
	assertThat(result5, is(@"another:"));
	assertThat(result6, is(@"<another:>"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassLocalProperty {
	// setup
	GBClassData *class = [GBTestObjectsRegistry classWithName:@"Class" methods:[GBTestObjectsRegistry propertyMethodWithArgument:@"method"], nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class, nil];
	GBCommentsProcessor *processor = [self processorWithStore:store context:class];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"method"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<method>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"method:"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<method:>"];
	NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"another"];
	NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"<another>"];
	// verify
	assertThat(result1, is(@"[method](#//api/name/method)"));
	assertThat(result2, is(@"[method](#//api/name/method)"));
	assertThat(result3, is(@"method:"));
	assertThat(result4, is(@"<method:>"));
	assertThat(result5, is(@"another"));
	assertThat(result6, is(@"<another>"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocolLocalInstanceMethod {
	// setup
	id method1 = [GBTestObjectsRegistry instanceMethodWithNames:@"method1", nil];
	id method2 = [GBTestObjectsRegistry instanceMethodWithNames:@"method2", nil];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, nil];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method2, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
	GBCommentsProcessor *processor1 = [self processorWithStore:store context:category];
	GBCommentsProcessor *processor2 = [self processorWithStore:store context:protocol];
	// execute
	NSString *result1 = [processor1 stringByConvertingCrossReferencesInString:@"method1:"];
	NSString *result2 = [processor1 stringByConvertingCrossReferencesInString:@"<method1:>"];
	NSString *result3 = [processor1 stringByConvertingCrossReferencesInString:@"method2:"];
	NSString *result4 = [processor2 stringByConvertingCrossReferencesInString:@"method2:"];
	NSString *result5 = [processor2 stringByConvertingCrossReferencesInString:@"<method2:>"];
	NSString *result6 = [processor2 stringByConvertingCrossReferencesInString:@"method1:"];
	// verify
	assertThat(result1, is(@"[method1:](#//api/name/method1:)"));
	assertThat(result2, is(@"[method1:](#//api/name/method1:)"));
	assertThat(result3, is(@"method2:"));
	assertThat(result4, is(@"[method2:](#//api/name/method2:)"));
	assertThat(result5, is(@"[method2:](#//api/name/method2:)"));
	assertThat(result6, is(@"method1:"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocolLocalClassMethod {
	// setup
	id method1 = [GBTestObjectsRegistry classMethodWithNames:@"method1", nil];
	id method2 = [GBTestObjectsRegistry classMethodWithNames:@"method2", nil];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, nil];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method2, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
	GBCommentsProcessor *processor1 = [self processorWithStore:store context:category];
	GBCommentsProcessor *processor2 = [self processorWithStore:store context:protocol];
	// execute
	NSString *result1 = [processor1 stringByConvertingCrossReferencesInString:@"method1:"];
	NSString *result2 = [processor1 stringByConvertingCrossReferencesInString:@"<method1:>"];
	NSString *result3 = [processor1 stringByConvertingCrossReferencesInString:@"method2:"];
	NSString *result4 = [processor2 stringByConvertingCrossReferencesInString:@"method2:"];
	NSString *result5 = [processor2 stringByConvertingCrossReferencesInString:@"<method2:>"];
	NSString *result6 = [processor2 stringByConvertingCrossReferencesInString:@"method1:"];
	// verify
	assertThat(result1, is(@"[method1:](#//api/name/method1:)"));
	assertThat(result2, is(@"[method1:](#//api/name/method1:)"));
	assertThat(result3, is(@"method2:"));
	assertThat(result4, is(@"[method2:](#//api/name/method2:)"));
	assertThat(result5, is(@"[method2:](#//api/name/method2:)"));
	assertThat(result6, is(@"method1:"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryAndProtocolLocalProperty {
	// setup
	id method1 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method1"];
	id method2 = [GBTestObjectsRegistry propertyMethodWithArgument:@"method2"];
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:method1, nil];
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:method2, nil];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, protocol, nil];
	GBCommentsProcessor *processor1 = [self processorWithStore:store context:category];
	GBCommentsProcessor *processor2 = [self processorWithStore:store context:protocol];
	// execute
	NSString *result1 = [processor1 stringByConvertingCrossReferencesInString:@"method1"];
	NSString *result2 = [processor1 stringByConvertingCrossReferencesInString:@"<method1>"];
	NSString *result3 = [processor1 stringByConvertingCrossReferencesInString:@"method2"];
	NSString *result4 = [processor2 stringByConvertingCrossReferencesInString:@"method2"];
	NSString *result5 = [processor2 stringByConvertingCrossReferencesInString:@"<method2>"];
	NSString *result6 = [processor2 stringByConvertingCrossReferencesInString:@"method1"];
	// verify
	assertThat(result1, is(@"[method1](#//api/name/method1)"));
	assertThat(result2, is(@"[method1](#//api/name/method1)"));
	assertThat(result3, is(@"method2"));
	assertThat(result4, is(@"[method2](#//api/name/method2)"));
	assertThat(result5, is(@"[method2](#//api/name/method2)"));
	assertThat(result6, is(@"method1"));
}

#pragma mark Remote members cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertClassRemoteInstanceMethod {
	// setup
	GBClassData *class1 = [GBTestObjectsRegistry classWithName:@"Class1" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
	GBClassData *class2 = [GBClassData classDataWithName:@"Class2"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:class1, class2, nil];
	GBCommentsProcessor *processor = [self processorWithStore:store context:class2];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Class1 method:]"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<[Class1 method:]>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-[Class1 method:]"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-[Class1 method:]>"];
	NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Unknown method:]"];
	NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"method:"];
	// verify
	assertThat(result1, is(@"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)"));
	assertThat(result2, is(@"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)"));
	assertThat(result3, is(@"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)"));
	assertThat(result4, is(@"[[Class1 method:]](../Classes/Class1.html#//api/name/method:)"));
	assertThat(result5, is(@"[Unknown method:]"));
	assertThat(result6, is(@"method:"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertCategoryRemoteInstanceMethod {
	// setup
	GBCategoryData *category = [GBTestObjectsRegistry categoryWithName:@"Category" className:@"Class" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:category, class, nil];
	GBCommentsProcessor *processor = [self processorWithStore:store context:class];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Class(Category) method:]"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<[Class(Category) method:]>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-[Class(Category) method:]"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-[Class(Category) method:]>"];
	NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Class(Unknown) method:]"];
	NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"[Unknown(Category) method:]"];
	// verify
	assertThat(result1, is(@"[[Class(Category) method:]](../Categories/Class(Category).html#//api/name/method:)"));
	assertThat(result2, is(@"[[Class(Category) method:]](../Categories/Class(Category).html#//api/name/method:)"));
	assertThat(result3, is(@"[[Class(Category) method:]](../Categories/Class(Category).html#//api/name/method:)"));
	assertThat(result4, is(@"[[Class(Category) method:]](../Categories/Class(Category).html#//api/name/method:)"));
	assertThat(result5, is(@"[Class(Unknown) method:]"));
	assertThat(result6, is(@"[Unknown(Category) method:]"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertProtocolRemoteInstanceMethod {
	// setup
	GBProtocolData *protocol = [GBTestObjectsRegistry protocolWithName:@"Protocol" methods:[GBTestObjectsRegistry instanceMethodWithNames:@"method", nil], nil];
	GBClassData *class = [GBClassData classDataWithName:@"Class"];
	GBStore *store = [GBTestObjectsRegistry storeWithObjects:protocol, class, nil];
	GBCommentsProcessor *processor = [self processorWithStore:store context:class];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"[Protocol method:]"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<[Protocol method:]>"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"-[Protocol method:]"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<-[Protocol method:]>"];
	NSString *result5 = [processor stringByConvertingCrossReferencesInString:@"[Unknown method:]"];
	NSString *result6 = [processor stringByConvertingCrossReferencesInString:@"method:"];
	// verify
	assertThat(result1, is(@"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)"));
	assertThat(result2, is(@"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)"));
	assertThat(result3, is(@"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)"));
	assertThat(result4, is(@"[[Protocol method:]](../Protocols/Protocol.html#//api/name/method:)"));
	assertThat(result5, is(@"[Unknown method:]"));
	assertThat(result6, is(@"method:"));
}

#pragma mark URL cross references detection

- (void)testStringByConvertingCrossReferencesInString_shouldConvertHTML {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"http://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"https://gentlebytes.com"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<http://gentlebytes.com>"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<https://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[http://gentlebytes.com](http://gentlebytes.com)"));
	assertThat(result2, is(@"[https://gentlebytes.com](https://gentlebytes.com)"));
	assertThat(result3, is(@"[http://gentlebytes.com](http://gentlebytes.com)"));
	assertThat(result4, is(@"[https://gentlebytes.com](https://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertFTP {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"ftp://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"ftps://gentlebytes.com"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<ftp://gentlebytes.com>"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<ftps://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[ftp://gentlebytes.com](ftp://gentlebytes.com)"));
	assertThat(result2, is(@"[ftps://gentlebytes.com](ftps://gentlebytes.com)"));
	assertThat(result3, is(@"[ftp://gentlebytes.com](ftp://gentlebytes.com)"));
	assertThat(result4, is(@"[ftps://gentlebytes.com](ftps://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertNewsAndRSS {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"news://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"rss://gentlebytes.com"];
	NSString *result3 = [processor stringByConvertingCrossReferencesInString:@"<news://gentlebytes.com>"];
	NSString *result4 = [processor stringByConvertingCrossReferencesInString:@"<rss://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[news://gentlebytes.com](news://gentlebytes.com)"));
	assertThat(result2, is(@"[rss://gentlebytes.com](rss://gentlebytes.com)"));
	assertThat(result3, is(@"[news://gentlebytes.com](news://gentlebytes.com)"));
	assertThat(result4, is(@"[rss://gentlebytes.com](rss://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertFile {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"file://gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<file://gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[file://gentlebytes.com](file://gentlebytes.com)"));
	assertThat(result2, is(@"[file://gentlebytes.com](file://gentlebytes.com)"));
}

- (void)testStringByConvertingCrossReferencesInString_shouldConvertMailto {
	// setup
	GBCommentsProcessor *processor = [GBCommentsProcessor processorWithSettingsProvider:[GBTestObjectsRegistry realSettingsProvider]];
	// execute
	NSString *result1 = [processor stringByConvertingCrossReferencesInString:@"mailto:appledoc@gentlebytes.com"];
	NSString *result2 = [processor stringByConvertingCrossReferencesInString:@"<mailto:appledoc@gentlebytes.com>"];
	// verify
	assertThat(result1, is(@"[appledoc@gentlebytes.com](mailto:appledoc@gentlebytes.com)"));
	assertThat(result2, is(@"[appledoc@gentlebytes.com](mailto:appledoc@gentlebytes.com)"));
}

#pragma mark Creation methods

- (GBCommentsProcessor *)processorWithStore:(id)store {
	// Creates a new GBCommentsProcessor using real settings and the given store.
	return [self processorWithStore:store context:nil];
}

- (GBCommentsProcessor *)processorWithStore:(id)store context:(id)context {
	// Creates a new GBCommentsProcessor using real settings and the given store and context.
	id settings = [GBTestObjectsRegistry realSettingsProvider];
	GBCommentsProcessor *result = [GBCommentsProcessor processorWithSettingsProvider:settings];
	[result setValue:store forKey:@"store"];
	[result setValue:context forKey:@"currentContext"];
	return result;
}

@end
