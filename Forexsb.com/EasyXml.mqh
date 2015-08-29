#property copyright "Copyright 2013, Paul van Hemmen"
#property link      "http://www.vanhemmen.de"
#property version   "1.00"
#property strict

//## Import Start

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

//+------------------------------------------------------------------+
//| macros                                                           |
//+------------------------------------------------------------------+
#define EASYXML_START_OPEN          "<"
#define EASYXML_START_CLOSE         ">"
#define EASYXML_SELFCLOSE           "/>"
#define EASYXML_CLOSE_OPEN          "</"
#define EASYXML_CLOSE_CLOSE         ">"
#define EASYXML_WHITESPACE          " \r\n\t"
#define EASYXML_LATIN               "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define EASYXML_CDATA_OPEN          "<![CDATA["
#define EASYXML_CDATA_CLOSE         "]]>"
#define EASYXML_COMMENT_OPEN        "<!--"
#define EASYXML_COMMENT_CLOSE       "-->"
#define EASYXML_PROLOG_OPEN         "<?xml"
#define EASYXML_PROLOG_CLOSE        "?>"
#define EASYXML_DOCTYPE_OPEN        "<!DOCTYPE"
#define EASYXML_DOCTYPE_CLOSE        ">"
#define EASYXML_ATTRIBUTE_SEPARATOR "="
#define EASYXML_ATTRIBUTE_COLON     "\"'"
#define EASYXML_XMLFILE_ENDING      ".xml"
#define HTTP_QUERY_CONTENT_LENGTH   5

#define EASYXML_ERR_CONNECTION_ATTEMPT      1
#define EASYXML_ERR_CONNECTION_OPEN         2
#define EASYXML_ERR_CONNECTION_URL          3
#define EASYXML_ERR_CONNECTION_FILEOPEN     4
#define EASYXML_ERR_CONNECTION_EMPTYSTREAM  5
#define EASYXML_INVALID_PROLOG              6
#define EASYXML_INVALID_COMMENT             7
#define EASYXML_INVALID_OPENTAG_START       8
#define EASYXML_INVALID_OPENTAG_CLOSE       9
#define EASYXML_INVALID_CLOSETAG            10
#define EASYXML_NO_CLOSETAG                 11
#define EASYXML_INVALID_CDATA               12
#define EASYXML_INVALID_ATTRIBUTE           13
#define EASYXML_INVALID_FILENAME            14
#define EASYXML_INVALID_DOCTYPE             15


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEasyXmlNode : public CObject
  {
private:
   CArrayObj        *ChildNodes;
   CArrayObj        *AttributeNodes;
   CEasyXmlNode     *ParentNode;
   string            sName;
   string            sValue;

public:
   void              SetName(string pName);
   void              SetValue(string pValue);
   void              SetAttribute(string pName,string pValue);

   string            GetName(void);
   string            GetValue(void);
   string            GetAttribute(string pName);

   CEasyXmlNode     *CreateChild(CEasyXmlNode *pChildNode);
   CEasyXmlNode     *CreateSibling(CEasyXmlNode *pSiblingNode);

   CEasyXmlNode     *Parent(void);
   void              Parent(CEasyXmlNode *pParentNode);

   CArrayObj        *Children(void);
   CArrayObj        *Attributes(void);
   CEasyXmlNode     *LastChild(void);
   CEasyXmlNode     *FirstChild(void);

                     CEasyXmlNode();
                    ~CEasyXmlNode();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEasyXmlNode::CEasyXmlNode()
  {
   ChildNodes=new CArrayObj;
   AttributeNodes=new CArrayObj;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CEasyXmlNode::~CEasyXmlNode()
  {
   if(CheckPointer(ChildNodes) == POINTER_DYNAMIC) 
     {
      for(int i = 0; i < ChildNodes.Total(); i++) 
        {
         ChildNodes.Delete(i);
        }
      delete ChildNodes;
     }
   if(CheckPointer(AttributeNodes) == POINTER_DYNAMIC) 
     {
      for(int i = 0; i < AttributeNodes.Total(); i++) 
        {
         AttributeNodes.Delete(i);
        }
      delete AttributeNodes;
     }
  }
//+------------------------------------------------------------------+
//| set tag name                                                     |
//+------------------------------------------------------------------+
void CEasyXmlNode::SetName(string pName)
  {
   sName=pName;
  }
//+------------------------------------------------------------------+
//| set tag content value                                            |
//+------------------------------------------------------------------+
void CEasyXmlNode::SetValue(string pValue)
  {
   sValue=pValue;
  }
//+------------------------------------------------------------------+
//| set attribute                                                    |
//+------------------------------------------------------------------+
void CEasyXmlNode::SetAttribute(string pName,string pValue)
  {
   CEasyXmlAttribute *Attribute=new CEasyXmlAttribute;

   Attribute.SetName(pName);
   Attribute.SetValue(pValue);

   AttributeNodes.Add(Attribute);
  }
//+------------------------------------------------------------------+
//| get attribute                                                    |
//+------------------------------------------------------------------+
string CEasyXmlNode::GetAttribute(string pName)
  {
   CEasyXmlAttribute *Attribute;

   for(int i=0; i<AttributeNodes.Total(); i++) 
     {
      Attribute=AttributeNodes.At(i);

      if(Attribute.GetName()==pName) 
        {
         return Attribute.GetValue();
        }
     }

   return("");
  }
//+------------------------------------------------------------------+
//| get tag name                                                     |
//+------------------------------------------------------------------+
string CEasyXmlNode::GetName(void)
  {
   return sName;
  }
//+------------------------------------------------------------------+
//| set tag content value                                            |
//+------------------------------------------------------------------+
string CEasyXmlNode::GetValue(void)
  {
   return sValue;
  }
//+------------------------------------------------------------------+
//| get child nodes                                                  |
//+------------------------------------------------------------------+
CArrayObj *CEasyXmlNode::Children(void)
  {
   return ChildNodes;
  }
//+------------------------------------------------------------------+
//| get Attributes                                                   |
//+------------------------------------------------------------------+
CArrayObj *CEasyXmlNode::Attributes(void)
  {
   return AttributeNodes;
  }
//+------------------------------------------------------------------+
//| create child node                                                |
//+------------------------------------------------------------------+
CEasyXmlNode *CEasyXmlNode::CreateChild(CEasyXmlNode *pChildNode)
  {
   pChildNode.Parent(GetPointer(this));
   ChildNodes.Add(pChildNode);

   return(ChildNodes.At(ChildNodes.Total()-1));
  }
//+------------------------------------------------------------------+
//| create sibling node                                              |
//+------------------------------------------------------------------+
CEasyXmlNode *CEasyXmlNode::CreateSibling(CEasyXmlNode *pSiblingNode)
  {
   pSiblingNode.Prev(GetPointer(this));
   GetPointer(this).Next(pSiblingNode);

   ParentNode.CreateChild(pSiblingNode);
   return ParentNode.LastChild();
  }
//+------------------------------------------------------------------+
//| get last child node in array                                     |
//+------------------------------------------------------------------+
CEasyXmlNode *CEasyXmlNode::FirstChild(void)
  {
   return ChildNodes.At(0);
  }
//+------------------------------------------------------------------+
//| get last child node in array                                     |
//+------------------------------------------------------------------+
CEasyXmlNode *CEasyXmlNode::LastChild(void)
  {
   return ChildNodes.At(ChildNodes.Total()-1);
  }
//+------------------------------------------------------------------+
//| get parent node                                                  |
//+------------------------------------------------------------------+
CEasyXmlNode *CEasyXmlNode::Parent(void)
  {
   return ParentNode;
  }
//+------------------------------------------------------------------+
//| set parent node                                                  |
//+------------------------------------------------------------------+
void CEasyXmlNode::Parent(CEasyXmlNode *pParentNode)
  {
   ParentNode=pParentNode;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| class declaration                                                |
//+------------------------------------------------------------------+
class CEasyXml
  {
private:
   // Properties
   CEasyXmlNode     *DocumentRoot;
   bool              blDebug;
   bool              blSaveToCache;
   string            sText;
   string            sFilename;
   int               Err;

   // Methods :: parsing
   bool              ParseRecursive(CEasyXmlNode *pActualNode,string &pText,int &pPos,int pLevel=0);
   bool              ParseAttributes(CEasyXmlNode *pActualNode,string pAttributes,string pDebugSpace);
   void              SkipWhitespace(string &pText,int &pPos);
   bool              SkipWhitespaceAndComments(string &pText,int &pPos,string pDebugSpace);
   bool              HasSiblings(string &pText,int &pPos);
   bool              EndOfXml(string &pText,int &pPos);
   bool              SkipProlog(string &pText,int &pPos);

   // Methods :: helpers
   bool              WriteStreamToCacheFile(string pStream);
   bool              Error(int pPos=-1,bool pClear=true);

public:
   // Methods :: parse by source
   bool              LoadXmlFromFile(string pFilename);
   bool              LoadXmlFromString(string pText);

   // Methods :: setters
   void              SetDebugging(bool pDebug);
   bool              SetUrlCacheFile(string pFilename);

   // Methods :: getters
   CEasyXmlNode     *GetDocumentRoot(void);
   string            GetText(void);
   void              Clear(void);

                     CEasyXml();
                    ~CEasyXml();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEasyXml::CEasyXml()
  {
   blDebug       = false;
   blSaveToCache = false;
   DocumentRoot  = new CEasyXmlNode;
  }
//+------------------------------------------------------------------+
//| Desctructor                                                      |
//+------------------------------------------------------------------+
CEasyXml::~CEasyXml()
  {
   if(CheckPointer(DocumentRoot)==POINTER_DYNAMIC) delete DocumentRoot;
  }
//+------------------------------------------------------------------+
//| enable debug output                                              |
//+------------------------------------------------------------------+
void CEasyXml::SetDebugging(bool pDebug)
  {
   blDebug=pDebug;
  }
//+------------------------------------------------------------------+
//| enable url caching                                               |
//+------------------------------------------------------------------+
bool CEasyXml::SetUrlCacheFile(string pFilename)
  {
   if(StringSubstr(pFilename,StringLen(pFilename)-StringLen(EASYXML_XMLFILE_ENDING),StringLen(EASYXML_XMLFILE_ENDING))==EASYXML_XMLFILE_ENDING) 
     {
      sFilename     = pFilename;
      blSaveToCache = true;
        } else {
      Err=EASYXML_INVALID_FILENAME;
      return(Error(-1,false));
     }

   return(true);
  }
//+------------------------------------------------------------------+
//| write stream to cache file                                       |
//+------------------------------------------------------------------+
bool CEasyXml::WriteStreamToCacheFile(string pStream)
  {
   int hFile=FileOpen(sFilename,FILE_BIN|FILE_WRITE);

   if(hFile==INVALID_HANDLE) 
     {
      Err = EASYXML_ERR_CONNECTION_FILEOPEN;
      return(false);
     }

   FileWriteString(hFile,pStream);
   FileClose(hFile);

   return(true);
  }
//+------------------------------------------------------------------+
//| Load XML by given file                                           |
//+------------------------------------------------------------------+
bool CEasyXml::LoadXmlFromFile(string pFilename)
  {
   string sStream;
   int    iStringSize;

   int hFile=FileOpen(pFilename,FILE_TXT|FILE_READ|FILE_ANSI);
   if(hFile==INVALID_HANDLE) 
     {
      Err = EASYXML_ERR_CONNECTION_FILEOPEN;
      return(Error());
     }

   while(!FileIsEnding(hFile))
     {
      iStringSize = FileReadInteger(hFile, INT_VALUE);
      sStream    += FileReadString(hFile, iStringSize);
     }

   FileClose(hFile);

   return(LoadXmlFromString(sStream));
  }
//+------------------------------------------------------------------+
//| Load XML by given string                                         |
//+------------------------------------------------------------------+
bool CEasyXml::LoadXmlFromString(string pText)
  {
   bool blSuccess = false;
   int  iPos      = 0;
   sText          = pText;

   StringTrimLeft(pText);
   StringTrimRight(pText);

// Skip xml prolog
   blSuccess=SkipProlog(pText,iPos);
   if(!blSuccess) return(Error(iPos));

// Parse
   blSuccess=ParseRecursive(DocumentRoot,pText,iPos);
   if(!blSuccess) return(Error(iPos));

   return(true);
  }
//+------------------------------------------------------------------+
//| XML recursive parser logic                                       |
//+------------------------------------------------------------------+
bool CEasyXml::ParseRecursive(CEasyXmlNode *pActualNode,string &pText,int &pPos,int pLevel=0)
  {
   bool blSuccess;
   bool blSibling=false;

//---
// At least parse one child element.
// Continue for as long as there are any siblings.
//---

   do 
     {

      // Debugging output vars
      string sDebugSpace;
      string sDebugOutput;

      // Indent debug output for better readability
      StringInit(sDebugSpace,pLevel*4,StringGetCharacter(" ",0));

      string sTagName;
      string sCloseTagName;
      string sTagContent;
      string sAttributes;

      // Create sibling node
      if(blSibling) 
        {
         pActualNode=pActualNode.CreateSibling(new CEasyXmlNode);
        }

      // Skip comments
      if(!SkipWhitespaceAndComments(pText,pPos,sDebugSpace)) return(false);

      //---
      // Get start tag. If it contains attributes, parse them seperately.´
      // If tag is self-closing, continue with siblings loop
      //---

      // Open tag
      if(StringFind(EASYXML_START_OPEN,StringSubstr(pText,pPos,1))==0) 
        {
         pPos++;
           } else {
         Err=EASYXML_INVALID_OPENTAG_START;
         return(false);
        }

      // Tag name
      while(StringFind(EASYXML_WHITESPACE,StringSubstr(pText,pPos,1))==-1 && 
            StringCompare(EASYXML_START_CLOSE,StringSubstr(pText,pPos,1))!=0 && 
            !EndOfXml(pText,pPos))
        {
         sTagName+=StringSubstr(pText,pPos,1);
         pPos++;
        }

      pActualNode.SetName(sTagName);

      // Debugging
      if(blDebug) Print(sDebugSpace,"<"+sTagName+"> D:",IntegerToString(pLevel)," | P:",pPos);

      SkipWhitespace(pText,pPos);

      // Attributes
      if(StringFind(EASYXML_LATIN,StringSubstr(pText,pPos,1))!=-1)
        {
         while(StringCompare(EASYXML_START_CLOSE,StringSubstr(pText, pPos, 1)) != 0 &&
               StringCompare(EASYXML_SELFCLOSE, StringSubstr(pText, pPos, 2)) != 0 &&
               !EndOfXml(pText,pPos))
           {
            sAttributes+=StringSubstr(pText,pPos,1);
            pPos++;
           }
         blSuccess=ParseAttributes(pActualNode,sAttributes,sDebugSpace);
         if(!blSuccess) return(false);
        }

      // Self closing tag
      if(StringCompare(EASYXML_SELFCLOSE,StringSubstr(pText,pPos,2))==0)
        {
         pPos+=2;
         SkipWhitespace(pText,pPos);

         // Detect if next sibling exists
         blSibling=HasSiblings(pText,pPos);

         continue;
        }

      // Start tag close
      if(StringCompare(EASYXML_START_CLOSE,StringSubstr(pText,pPos,1))==0) 
        {
         pPos++;
           } else {
         Err=EASYXML_INVALID_OPENTAG_CLOSE;
         return(false);
        }

      // Skip comments
      if(!SkipWhitespaceAndComments(pText,pPos,sDebugSpace)) return(false);

      //---
      // Parse next lower level tag and/or read text content
      //---

      // Next level tag
      if(StringCompare(EASYXML_START_OPEN,StringSubstr(pText,pPos,1))==0 && 
         StringCompare(EASYXML_CLOSE_OPEN,StringSubstr(pText,pPos,2))!=0 && 
         StringCompare(EASYXML_CDATA_OPEN,StringSubstr(pText,pPos,StringLen(EASYXML_CDATA_OPEN)))!=0)
        {
         // Delve deeper
         pActualNode=pActualNode.CreateChild(new CEasyXmlNode);

         blSuccess=ParseRecursive(pActualNode,pText,pPos,pLevel+1);
         if(!blSuccess) return(false);

         pActualNode=pActualNode.Parent();
        }

      // Read text content, even if it follows a closing tag
      if(StringCompare(EASYXML_CDATA_OPEN,StringSubstr(pText,pPos,StringLen(EASYXML_CDATA_OPEN)))!=0)
        {
         // Tags in between text won't get parsed as XML nodes
         while(StringCompare(EASYXML_CLOSE_OPEN+sTagName,StringSubstr(pText,pPos,StringLen(EASYXML_CLOSE_OPEN+sTagName)))!=0 && 
               !EndOfXml(pText,pPos))
           {
            sTagContent+=StringSubstr(pText,pPos,1);
            pPos++;
           }
         pActualNode.SetValue(sTagContent);
        }
      // Else read CDATA content, if there is any
      else
        {
         int iClose=StringFind(pText,EASYXML_CDATA_CLOSE,pPos+StringLen(EASYXML_CDATA_OPEN));

         if(iClose>0) 
           {
            sTagContent = StringSubstr(pText, pPos + StringLen(EASYXML_CDATA_OPEN), (iClose - pPos - StringLen(EASYXML_CDATA_OPEN)));
            pPos        = iClose + StringLen(EASYXML_CDATA_CLOSE);
              } else {
            Err=EASYXML_INVALID_CDATA;
            return(false);
           }
         pActualNode.SetValue(sTagContent);
        }

      // Debugging
      if(blDebug && StringLen(sTagContent)!=0)
        {
         sDebugOutput=sTagContent;
         StringTrimLeft(sDebugOutput);
         sDebugOutput=(StringLen(sDebugOutput)>=50) ? StringSubstr(sDebugOutput,0,50)+"..." : sDebugOutput;
         Print(sDebugSpace,"  ### Content ###    "+sDebugOutput);
        }

      SkipWhitespace(pText,pPos);

      //---
      // Get end tag and compare it to start tag. return to upper level if valid
      //---

      if(StringFind(EASYXML_CLOSE_OPEN,StringSubstr(pText,pPos,2))==0) 
        {
         pPos+=2;
           } else {
         Err=EASYXML_NO_CLOSETAG;
         return(false);
        }

      //read end tag name
      while(StringFind(EASYXML_CLOSE_CLOSE,StringSubstr(pText,pPos,1))==-1 && !EndOfXml(pText,pPos))
        {
         sCloseTagName+=StringSubstr(pText,pPos,1);
         pPos++;
        }

      if(blDebug) Print(sDebugSpace,"</",sCloseTagName,"> D:",IntegerToString(pLevel)," | P:",pPos);

      //compare start and end tag names
      if(StringCompare(sCloseTagName,sTagName,false)==0) 
        {
         pPos++;
           } else {
         Err=EASYXML_INVALID_CLOSETAG;
         return(false);
        }

      // Skip comments
      if(!SkipWhitespaceAndComments(pText,pPos,sDebugSpace)) return(false);

      // Detect if next sibling exists
      blSibling=HasSiblings(pText,pPos);

     }
   while(blSibling==true);

//return to upper level
   return(true);
  }
//+------------------------------------------------------------------+
//| pares attributes                                                 |
//+------------------------------------------------------------------+
bool CEasyXml::ParseAttributes(CEasyXmlNode *pActualNode,string pAttributes,string pDebugSpace)
  {
   int iAttrPos        = 0;
   int iValidAttrStart = 0;
   int iValidAttrEnd   = 0;

   string sDebugOutput;

   while(!EndOfXml(pAttributes,iAttrPos))
     {
      string sAttributeName;
      string sAttributeValue;
      string sAttributeValueColon;

      // Some wellformed validity test
      if(StringFind(EASYXML_LATIN,StringSubstr(pAttributes,iAttrPos,1))!=-1) 
        {
         iValidAttrStart++;
        }

      // Read Attributename
      while(StringCompare(EASYXML_ATTRIBUTE_SEPARATOR,StringSubstr(pAttributes,iAttrPos,1))!=0)
        {
         sAttributeName+=StringSubstr(pAttributes,iAttrPos,1);
         iAttrPos++;
        }

      // Skip attribute separator
      if(StringCompare(EASYXML_ATTRIBUTE_SEPARATOR,StringSubstr(pAttributes,iAttrPos,1))==0) 
        {
         iAttrPos++;
        }

      // Read attribute value. Store Open Colon and use for further comparison
      if(StringFind(EASYXML_ATTRIBUTE_COLON,StringSubstr(pAttributes,iAttrPos,1))!=-1) 
        {
         sAttributeValueColon=StringSubstr(pAttributes,iAttrPos,1);
         iAttrPos++;
        }

      while(StringFind(sAttributeValueColon,StringSubstr(pAttributes,iAttrPos,1))==-1)
        {
         sAttributeValue+=StringSubstr(pAttributes,iAttrPos,1);
         iAttrPos++;
        }

      if(StringFind(sAttributeValueColon,StringSubstr(pAttributes,iAttrPos,1))!=-1) 
        {
         iAttrPos++;
         iValidAttrEnd++;
        }

      // If attribute is wellformed, set attribute to node
      if(iValidAttrStart==iValidAttrEnd) 
        {
         pActualNode.SetAttribute(sAttributeName,sAttributeValue);
           } else {
         Err=EASYXML_INVALID_ATTRIBUTE;
         return(false);
        }

      // Debugging
      if(blDebug) 
        {
         sDebugOutput += (StringLen(sDebugOutput) != 0) ? " | " : "";
         sDebugOutput += IntegerToString(iValidAttrEnd) + ": " + sAttributeName + " -> " + sAttributeValue;
        }

      SkipWhitespace(pAttributes,iAttrPos);
     }

// Debugging
   if(blDebug) Print(pDebugSpace,"  ### Attributes ###    ",sDebugOutput);

   return(true);
  }
//+------------------------------------------------------------------+
//| skip whitespace                                                  |
//+------------------------------------------------------------------+
void CEasyXml::SkipWhitespace(string &pText,int &pPos)
  {
   while(StringFind(EASYXML_WHITESPACE,StringSubstr(pText,pPos,1))!=-1) 
     {
      pPos++;
     }
  }
//+------------------------------------------------------------------+
//| check if node has siblings                                       |
//+------------------------------------------------------------------+
bool CEasyXml::HasSiblings(string &pText,int &pPos)
  {
   if(StringFind(EASYXML_START_OPEN,StringSubstr(pText,pPos,1))==0 && 
      StringFind(EASYXML_CLOSE_OPEN,StringSubstr(pText,pPos,2))==-1) 
     {
      return true;
        } else {
      return false;
     }
  }
//+------------------------------------------------------------------+
//| check for end of xml                                             |
//+------------------------------------------------------------------+
bool CEasyXml::EndOfXml(string &pText,int &pPos)
  {
   return !(pPos<StringLen(pText));
  }
//+------------------------------------------------------------------+
//| skip xml prolog                                                  |
//+------------------------------------------------------------------+
bool CEasyXml::SkipProlog(string &pText,int &pPos)
  {
// Skip xml declaration
   if(StringCompare(EASYXML_PROLOG_OPEN,StringSubstr(pText,pPos,StringLen(EASYXML_PROLOG_OPEN)))==0)
     {
      int iClose=StringFind(pText,EASYXML_PROLOG_CLOSE,pPos+StringLen(EASYXML_PROLOG_OPEN));

      if(blDebug) Print("### Prolog ###    ",StringSubstr(pText,pPos,(iClose-pPos)+StringLen(EASYXML_PROLOG_CLOSE)));

      if(iClose>0) 
        {
         pPos=iClose+StringLen(EASYXML_PROLOG_CLOSE);
           } else {
         Err=EASYXML_INVALID_PROLOG;
         return(false);
        }
     }

// Skip comments
   if(!SkipWhitespaceAndComments(pText,pPos,"")) return(false);

// Skip doctype
   if(StringCompare(EASYXML_DOCTYPE_OPEN,StringSubstr(pText,pPos,StringLen(EASYXML_DOCTYPE_OPEN)))==0)
     {
      int iClose=StringFind(pText,EASYXML_DOCTYPE_CLOSE,pPos+StringLen(EASYXML_DOCTYPE_OPEN));

      if(blDebug) Print("### DOCTYPE ###    ",StringSubstr(pText,pPos,(iClose-pPos)+StringLen(EASYXML_DOCTYPE_CLOSE)));

      if(iClose>0) 
        {
         pPos=iClose+StringLen(EASYXML_DOCTYPE_CLOSE);
           } else {
         Err=EASYXML_INVALID_DOCTYPE;
         return(false);
        }
     }

// Skip comments
   if(!SkipWhitespaceAndComments(pText,pPos,"")) return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| skip xml comments                                                |
//+------------------------------------------------------------------+
bool CEasyXml::SkipWhitespaceAndComments(string &pText,int &pPos,string pDebugSpace)
  {
   bool blNextComment=false;

// Do while there are consecutive comments
   do
     {
      SkipWhitespace(pText,pPos);

      if(StringCompare(EASYXML_COMMENT_OPEN,StringSubstr(pText,pPos,StringLen(EASYXML_COMMENT_OPEN)))==0)
        {
         int iClose=StringFind(pText,EASYXML_COMMENT_CLOSE,pPos+StringLen(EASYXML_COMMENT_OPEN));

         if(blDebug) Print(pDebugSpace,"  ### Comment ###    ",StringSubstr(pText,pPos,(iClose-pPos)+StringLen(EASYXML_COMMENT_CLOSE)));

         if(iClose>0) 
           {
            pPos=iClose+StringLen(EASYXML_COMMENT_CLOSE);
              } else {
            Err=EASYXML_INVALID_COMMENT;
            return(false);
           }
        }

      SkipWhitespace(pText,pPos);

      if(StringCompare(EASYXML_COMMENT_OPEN,StringSubstr(pText,pPos,StringLen(EASYXML_COMMENT_OPEN)))==0) 
        {
         blNextComment=true;
           } else {
         blNextComment=false;
        }

     }
   while(blNextComment==true);

   return(true);
  }
//+------------------------------------------------------------------+
//| error handling                                                   |
//+------------------------------------------------------------------+
bool CEasyXml::Error(int pPos=-1,bool pClear=true)
  {
   if(pClear) Clear();

   Print(EasyXmlError(Err,pPos));
   return(false);
  }
//+------------------------------------------------------------------+
//| get paresd document root                                         |
//+------------------------------------------------------------------+
CEasyXmlNode *CEasyXml::GetDocumentRoot(void)
  {
   return DocumentRoot;
  }
//+------------------------------------------------------------------+
//| return unparsed text                                             |
//+------------------------------------------------------------------+
string CEasyXml::GetText(void)
  {
   return sText;
  }
//+------------------------------------------------------------------+
//| Clear the doc tree                                               |
//+------------------------------------------------------------------+
void CEasyXml::Clear(void)
  {
   StringInit(sText);
   if(CheckPointer(DocumentRoot)==POINTER_DYNAMIC) delete DocumentRoot;

   DocumentRoot=new CEasyXmlNode;
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEasyXmlAttribute : public CObject
  {
private:
   string            sName;
   string            sValue;

public:
   void              SetName(string pName);
   void              SetValue(string pValue);

   string            GetName(void);
   string            GetValue(void);

                     CEasyXmlAttribute();
                    ~CEasyXmlAttribute();
  };
//+------------------------------------------------------------------+
//| constructor                                                      |
//+------------------------------------------------------------------+
CEasyXmlAttribute::CEasyXmlAttribute()
  {
  }
//+------------------------------------------------------------------+
//| destructor                                                       |
//+------------------------------------------------------------------+
CEasyXmlAttribute::~CEasyXmlAttribute()
  {
  }
//+------------------------------------------------------------------+
//| set attribute name                                               |
//+------------------------------------------------------------------+
void CEasyXmlAttribute::SetName(string pName)
  {
   sName=pName;
  }
//+------------------------------------------------------------------+
//| set attribute value                                              |
//+------------------------------------------------------------------+
void CEasyXmlAttribute::SetValue(string pValue)
  {
   sValue=pValue;
  }
//+------------------------------------------------------------------+
//| get attribute name                                               |
//+------------------------------------------------------------------+
string CEasyXmlAttribute::GetName(void)
  {
   return sName;
  }
//+------------------------------------------------------------------+
//| get attribute value                                              |
//+------------------------------------------------------------------+
string CEasyXmlAttribute::GetValue(void)
  {
   return sValue;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| returns trade server return code description                     |
//+------------------------------------------------------------------+
string EasyXmlError(int return_code,int pPos=-1)
  {
   string sErrorDescription;

   switch(return_code)
     {
      case EASYXML_ERR_CONNECTION_ATTEMPT:        sErrorDescription = "Error in call of InternetAttemptConnect()"; break;
      case EASYXML_ERR_CONNECTION_OPEN:           sErrorDescription = "Error in call of InternetOpenW()"; break;
      case EASYXML_ERR_CONNECTION_URL:            sErrorDescription = "Error in call of InternetOpenUrlW()"; break;
      case EASYXML_ERR_CONNECTION_FILEOPEN:       sErrorDescription = "Error in call of FileOpen()"; break;
      case EASYXML_ERR_CONNECTION_EMPTYSTREAM:    sErrorDescription = "No return data from URL"; break;
      case EASYXML_INVALID_PROLOG:                sErrorDescription = "Invalid Prologue"; break;
      case EASYXML_INVALID_COMMENT:               sErrorDescription = "Invalid Comment"; break;
      case EASYXML_INVALID_OPENTAG_START:         sErrorDescription = "Invalid Character found. Should be the beginning of an open tag"; break;
      case EASYXML_INVALID_OPENTAG_CLOSE:         sErrorDescription = "Invalid Character found. Should be the close of an open tag"; break;
      case EASYXML_INVALID_CLOSETAG:              sErrorDescription = "Invalid Close Tag. Tags must match!"; break;
      case EASYXML_NO_CLOSETAG:                   sErrorDescription = "No Close Tag found"; break;
      case EASYXML_INVALID_CDATA:                 sErrorDescription = "Invalid CDATA"; break;
      case EASYXML_INVALID_ATTRIBUTE:             sErrorDescription = "Invalid Attribute"; break;
      case EASYXML_INVALID_FILENAME:              sErrorDescription = "Invalid Cach File Name"; break;
      case EASYXML_INVALID_DOCTYPE:               sErrorDescription = "Invalid Doctype"; break;
     }

   if(pPos!=-1) 
     {
      sErrorDescription+=" P:"+IntegerToString(pPos);
     }

   return("*** "+sErrorDescription+" ***");
  }
//+------------------------------------------------------------------+
