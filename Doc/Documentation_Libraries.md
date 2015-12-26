Library Names
=============

Libraries list
--------------

Here is the list of the libraries used in this project and the eventual modifications brought.

|Library Name|Modifications|Comment|
|:-----------|:------------|:-----------|
|FreeType    |Used AS IS, no modification|[*4](#note4)|
|libCurl     |Used AS IS, no modification||
|libogg      |Used AS IS, no modification|Used only for Win32 platform.|
|libvorbis   |Used AS IS, no modification|Used only for Win32 platform.|
|MiniZip     |Few modifications including some #define for a cleaner implementation.||
|mp3Lame     |Used AS IS, no modification|[*2](#note2)|
|MsgPack     |Used AS IS, no modification||
|OpenSSL     |Used AS IS, no modification||
|Sha1        |[Implementation of the following algorithm](http://en.wikipedia.org/wiki/SHA-1#SHA-1_pseudocode)||
|SQLite      |[*3](#note3)|Was "hacked" (too dirty for saying modified) to support encryption.|
|Tremolo     |Used AS IS, no modification|Used only for Android & ARM platform for now.|
|utf8_converter|removed dependency and re-defined errcodes|| 
|YAJL        |Modified to support binary JSON and for debug purpose|[*1](#note1)|
|Zlib        |Used AS IS, no modification||

C# -> CPP Prototype compiler
----------------------------

- N/A	(Parser C#)	

  Modified, Grammar used for C++/C# parser for C# compiler

- N/A	(UTF8 Parser)

  As is, UTF8 string parser for C# Compiler

### Notes

<a name="note1">*1</a>
Added code to check the first bytes of the stream to decode and decide to switch to other parser
that perform the same callback to user code as YAJL, as an end result, we can send different stream formats
but the user parser implementing the callbacks from YAJL will stay the same.

<a name="note2">*2</a>
Used for mp3 decoding for Win32 platform, but now we could remove it and avoid annoying MP3 license issues.

<a name="note3">*3</a>
Version used : 3.7.11
Modified functions : 
- hasHotJournal
- sqlite3PagerSharedLock
Added functions : 
- getVFSList

<a name="note4">*4</a>
You can find 2 folders libs/freeType and libs/libfreetype2
freeType is a bit more recent (it is NOT freeType 1).
libfreetype2 is already compiled for Android.

# LICENSES

|Library Name		|License Type          |Version (if known)|Link                     |
|:------------------|:---------------------|:-----------------|:------------------------|
|FreeType           |FTL                   |                  |http://git.savannah.gnu.org/cgit/freetype/freetype2.git/tree/docs/FTL.TXT|
|IPA Gothic Font    |IPA Font License v1.0|3|http://ipafont.ipa.go.jp/ipa_font_license_v1.html [*1](#licenses_note_1)|
|libCurl            |MIT/X derivate licence|7.29.0            |http://curl.haxx.se/docs/copyright.html|
|libogg				|New BSD License       |                  |http://svn.xiph.org/trunk/ogg/COPYING|
|libvorbis			|New BSD License       |                  |http://svn.xiph.org/trunk/vorbis/COPYING|
|MiniZip            |Undefined             |1.1               |http://www.winimage.com/zLibDll/minizip.html|
|mp3Lame            |LGPL                  |1.189.2.1         |http://en.wikipedia.org/wiki/LAME#Patents_and_legal_issues|
|MsgPack            |Apache License, V2    |0.5.7             |https://github.com/msgpack/msgpack-c/blob/master/LICENSE|
|openSSL            |OpenSSL License       |                  |https://www.openssl.org/source/license.html|
|Sha1|See link      |                      |https://en.wikipedia.org/wiki/Wikipedia:Text_of_Creative_Commons_Attribution-ShareAlike_3.0_Unported_License|
|SQLite             |Public Domain         |3.7.11            |http://www.sqlite.org/copyright.html| 
|Tremolo            |BSD                   |                  |http://wss.co.uk/pinknoise/tremolo/|
|utf8_converter     |has been described to source code.|      |http://www.opensource.apple.com/source/Heimdal/Heimdal-247.6/lib/wind/utf8.c
|YAJL               |ISC licens:   |                  |http://lloyd.github.io/yajl/|
|Zlib               |Undefined             |                  |http://www.winimage.com/zLibDll/minizip.html|

### Licenses notes

<a name="licenses_note_1">*1</a>
also included a copy in this directory (IPA_Font_License_Agreement_v1.0.txt) under license requirement.

C# -> CPP Prototype compiler
----------------------------

### Parser C#

- http://www.cs.may.ie/~jpower/Research/csharp/Index.html

### UTF8 Parser

- http://bjoern.hoehrmann.de/utf-8/decoder/dfa/
