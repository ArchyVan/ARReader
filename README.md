![ARReader](./ARreaderComposing.png
)

<p align="center">
<a href="https://img.shields.io/badge/Language-%20Objective--C%20-orange.svg"><img src="https://img.shields.io/badge/Language-%20Objective--C%20-orange.svg"></a>
<a href="https://travis-ci.org/ArchyVan/ARReader"><img src="https://travis-ci.org/ArchyVan/ARReader.svg?branch=master"></a>
<img src="https://img.shields.io/badge/license-MIT-blue.svg">
<a href="https://img.shields.io/badge/platform-%20iOS%20-lightgrey.svg"><img src="https://img.shields.io/badge/platform-%20iOS%20-lightgrey.svg"></a>
</p>

**ARReader** is a simple *READRER* based on the **ARComposing** typesetting engine, complete Objective-C implementation,The implementation for part of components is reference to [tangqiaoboy](https://github.com/tangqiaoboy), [ibireme](https://github.com/ibireme) source code.

## Installation
### CocoaPods
To integrate ARComposing into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'your_app' do
  pod 'ARComposing', '~> 0.0.1'
end
```
Then, run the following command:

```bash
$ pod install
```
You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

### Manually
You can just download the lastest zip from this page and drag all things under "ARComposing" folder into your project. Then you just need to import the header file:

```c
#import "ARComposing.h"
```
## Usage
You can find the full API documentation at CocoaDocs.
### Basic
Import ARComposing into your source files in which you want to use the framework.

```c
#import "ARComposing.h"
```
### Page Parser
```objective-c
//The Content you want to parse
NSString *content = ...

//Config The Parser
ARPageParser *parser = [ARPageParser sharedInstance];
parser.fontSize = 21;
parser.titleLength = 11;
parser.indent = YES;
parser.pageSize = CGSizeMake(ScreenWidth - 30, ScreenHeight - 80);
parser.lineSpacing = 10;
parser.textAlignment = NSTextAlignmentJustified;
pageParser parserContent:content]
```

## Stucture

| Name | Description |
| --- |:----:|
| ARComposingKit | Reader UI Component |
| ARAsyncLayer |  Asynchronous Layer |
| ARComposingUtils | Composing Utilities |
| ARPageData | Page Data |
| ARPageParser | The Core Parser |

## Features

- [x] 不同排版样式切分
- [x] 异步图层绘制
- [x] 可编辑属性
- [ ] 全选文本
- [ ] 光标可控性
- [ ] 图文混合类型文本
- [ ] The CocoaDocs



