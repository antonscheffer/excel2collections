declare
  l_log clob;
  l_varchar2_sz pls_integer;
  l_collection_base varchar2(32767);
  type tp_col_mem is table of varchar2(32767);
  l_col_mem tp_col_mem;
  c_lob_duration constant pls_integer := dbms_lob.call;
  c_LOCAL_FILE_HEADER        constant raw(4) := hextoraw( '504B0304' ); -- Local file header signature
  c_CENTRAL_FILE_HEADER      constant raw(4) := hextoraw( '504B0102' ); -- Central directory file header signature
  c_END_OF_CENTRAL_DIRECTORY constant raw(4) := hextoraw( '504B0506' ); -- End of central directory signature
  --
  type tp_zip_info is record
    ( len integer
    , cnt integer
    , len_cd integer
    , idx_cd integer
    , idx_eocd integer
    );
  --
  type tp_cfh is record
    ( offset integer
    , compressed_len integer
    , original_len integer
    , len pls_integer
    , n   pls_integer
    , m   pls_integer
    , k   pls_integer
    , utf8 boolean
    , encrypted boolean
    , crc32 raw(4)
    , external_file_attr raw(4)
    , encoding varchar2(3999)
    , idx   integer
    , name1 raw(32767)
    );
  --
  function little_endian( p_num raw, p_pos pls_integer := 1, p_bytes pls_integer := null )
  return integer
  is
  begin
    return to_number( utl_raw.reverse( utl_raw.substr( p_num, p_pos, p_bytes ) ), 'XXXXXXXXXXXXXXXX' );
  end;
  --
  function get_encoding( p_encoding varchar2 := null )
  return varchar2
  is
    l_encoding varchar2(32767);
  begin
    if p_encoding is not null
    then
      if nls_charset_id( p_encoding ) is null
      then
        l_encoding := utl_i18n.map_charset( p_encoding, utl_i18n.GENERIC_CONTEXT, utl_i18n.IANA_TO_ORACLE );
      else
        l_encoding := p_encoding;
      end if;
    end if;
    return coalesce( l_encoding, 'US8PC437' ); -- IBM codepage 437
  end;
  --
  function char2raw( p_txt varchar2 character set any_cs, p_encoding varchar2 := null )
  return raw
  is
  begin
    if isnchar( p_txt )
    then -- on my 12.1 database, which is not AL32UTF8,
         -- utl_i18n.string_to_raw( p_txt, get_encoding( p_encoding ) does not work
      return utl_raw.convert( utl_i18n.string_to_raw( p_txt )
                            , get_encoding( p_encoding )
                            , nls_charset_name( nls_charset_id( 'NCHAR_CS' ) )
                            );
    end if;
    return utl_i18n.string_to_raw( p_txt, get_encoding( p_encoding ) );
  end;
  --
  procedure get_zip_info( p_zip blob, p_info out tp_zip_info )
  is
    l_ind integer;
    l_buf_sz pls_integer := 2024;
    l_start_buf integer;
    l_buf raw(32767);
  begin
    p_info.len := nvl( dbms_lob.getlength( p_zip ), 0 );
    if p_info.len < 22
    then -- no (zip) file or empty zip file
      return;
    end if;
    l_start_buf := greatest( p_info.len - l_buf_sz + 1, 1 );
    l_buf := dbms_lob.substr( p_zip, l_buf_sz, l_start_buf );
    l_ind := utl_raw.length( l_buf ) - 21;
    loop
      exit when l_ind < 1 or utl_raw.substr( l_buf, l_ind, 4 ) = c_END_OF_CENTRAL_DIRECTORY;
      l_ind := l_ind - 1;
    end loop;
    if l_ind > 0
    then
      l_ind := l_ind + l_start_buf - 1;
    else
      l_ind := p_info.len - 21;
      loop
        exit when l_ind < 1 or dbms_lob.substr( p_zip, 4, l_ind ) = c_END_OF_CENTRAL_DIRECTORY;
        l_ind := l_ind - 1;
      end loop;
    end if;
    if l_ind <= 0
    then
      raise_application_error( -20001, 'Error parsing the zipfile' );
    end if;
    l_buf := dbms_lob.substr( p_zip, 22, l_ind );
    if    utl_raw.substr( l_buf, 5, 2 ) != utl_raw.substr( l_buf, 7, 2 )  -- this disk = disk with start of Central Dir
       or utl_raw.substr( l_buf, 9, 2 ) != utl_raw.substr( l_buf, 11, 2 ) -- complete CD on this disk
    then
      raise_application_error( -20003, 'Error parsing the zipfile' );
    end if;
    p_info.idx_eocd := l_ind;
    p_info.idx_cd := little_endian( l_buf, 17, 4 ) + 1;
    p_info.cnt := little_endian( l_buf, 9, 2 );
    p_info.len_cd := p_info.idx_eocd - p_info.idx_cd;
  end;
  --
  function parse_central_file_header( p_zip blob, p_ind integer, p_cfh out tp_cfh )
  return boolean
  is
    l_tmp pls_integer;
    l_len pls_integer;
    l_buf raw(32767);
  begin
    l_buf := dbms_lob.substr( p_zip, 46, p_ind );
    if utl_raw.substr( l_buf, 1, 4 ) != c_CENTRAL_FILE_HEADER
    then
      return false;
    end if;
    p_cfh.crc32 := utl_raw.substr( l_buf, 17, 4 );
    p_cfh.n := little_endian( l_buf, 29, 2 );
    p_cfh.m := little_endian( l_buf, 31, 2 );
    p_cfh.k := little_endian( l_buf, 33, 2 );
    p_cfh.len := 46 + p_cfh.n + p_cfh.m + p_cfh.k;
    --
    p_cfh.utf8 := bitand( to_number( utl_raw.substr( l_buf, 10, 1 ), 'XX' ), 8 ) > 0;
    if p_cfh.n > 0
    then
      p_cfh.name1 := dbms_lob.substr( p_zip, least( p_cfh.n, 32767 ), p_ind + 46 );
    end if;
    --
    p_cfh.compressed_len := little_endian( l_buf, 21, 4 );
    p_cfh.original_len := little_endian( l_buf, 25, 4 );
    p_cfh.offset := little_endian( l_buf, 43, 4 );
    --
    return true;
  end;
  --
  function get_central_file_header
    ( p_zip      blob
    , p_name     varchar2 character set any_cs
    , p_idx      number
    , p_encoding varchar2
    , p_cfh      out tp_cfh
    )
  return boolean
  is
    l_rv        boolean;
    l_ind       integer;
    l_idx       integer;
    l_info      tp_zip_info;
    l_name      raw(32767);
    l_utf8_name raw(32767);
  begin
    if p_name is null and p_idx is null
    then
      return false;
    end if;
    get_zip_info( p_zip, l_info );
    if nvl( l_info.cnt, 0 ) < 1
    then -- no (zip) file or empty zip file
      return false;
    end if;
    --
    if p_name is not null
    then
      l_name := char2raw( p_name, p_encoding );
      l_utf8_name := char2raw( p_name, 'AL32UTF8' );
    end if;
    --
    l_rv := false;
    l_ind := l_info.idx_cd;
    l_idx := 1;
    loop
      exit when not parse_central_file_header( p_zip, l_ind, p_cfh );
      if l_idx = p_idx
         or p_cfh.name1 = case when p_cfh.utf8 then l_utf8_name else l_name end
      then
        l_rv := true;
        exit;
      end if;
      l_ind := l_ind + p_cfh.len;
      l_idx := l_idx + 1;
    end loop;
    --
    p_cfh.idx := l_idx;
    p_cfh.encoding := get_encoding( p_encoding );
    return l_rv;
  end;
  --
  function parse_file( p_zipped_blob blob, p_fh in out tp_cfh )
  return blob
  is
    l_rv blob;
    l_buf raw(3999);
    l_compression_method varchar2(4);
    l_n integer;
    l_m integer;
    l_crc raw(4);
  begin
    if p_fh.original_len is null
    then
      raise_application_error( -20006, 'File not found' );
    end if;
    if nvl( p_fh.original_len, 0 ) = 0
    then
      return empty_blob();
    end if;
    l_buf := dbms_lob.substr( p_zipped_blob, 30, p_fh.offset + 1 );
    if utl_raw.substr( l_buf, 1, 4 ) != c_LOCAL_FILE_HEADER
    then
      raise_application_error( -20007, 'Error parsing the zipfile' );
    end if;
    l_compression_method := utl_raw.substr( l_buf, 9, 2 );
    l_n := little_endian( l_buf, 27, 2 );
    l_m := little_endian( l_buf, 29, 2 );
    if l_compression_method = '0800'
    then
      if p_fh.original_len < 32767 and p_fh.compressed_len < 32748
      then
        return utl_compress.lz_uncompress( utl_raw.concat
                 ( hextoraw( '1F8B0800000000000003' )
                 , dbms_lob.substr( p_zipped_blob, p_fh.compressed_len, p_fh.offset + 31 + l_n + l_m )
                 , p_fh.crc32
                 , utl_raw.substr( utl_raw.reverse( to_char( p_fh.original_len, 'fm0XXXXXXXXXXXXXXX' ) ), 1, 4 )
                 ) );
      end if;
      l_rv := hextoraw( '1F8B0800000000000003' ); -- gzip header
      dbms_lob.copy( l_rv
                   , p_zipped_blob
                   , p_fh.compressed_len
                   , 11
                   , p_fh.offset + 31 + l_n + l_m
                   );
      dbms_lob.append( l_rv
                     , utl_raw.concat( p_fh.crc32
                                     , utl_raw.substr( utl_raw.reverse( to_char( p_fh.original_len, 'fm0XXXXXXXXXXXXXXX' ) ), 1, 4 )
                                     )
                     );
      return utl_compress.lz_uncompress( l_rv );
    elsif l_compression_method = '0000'
    then
      if p_fh.original_len < 32767 and p_fh.compressed_len < 32767
      then
        return dbms_lob.substr( p_zipped_blob
                              , p_fh.compressed_len
                              , p_fh.offset + 31 + l_n + l_m
                              );
      end if;
      dbms_lob.createtemporary( l_rv, true, c_lob_duration );
      dbms_lob.copy( l_rv
                   , p_zipped_blob
                   , p_fh.compressed_len
                   , 1
                   , p_fh.offset + 31 + l_n + l_m
                   );
      return l_rv;
    end if;
    raise_application_error( -20008, 'Unhandled compression method ' || l_compression_method );
  end parse_file;
  --
  function get_count( p_zipped_blob blob )
  return integer
  is
    l_info tp_zip_info;
  begin
    get_zip_info( p_zipped_blob, l_info );
    return nvl( l_info.cnt, 0 );
  end;
  --
  function col_alfan( p_col varchar2 )
  return pls_integer
  is
    l_col varchar2(1000) := rtrim( p_col, '0123456789' );
  begin
    return ascii( substr( l_col, -1 ) ) - 64
         + nvl( ( ascii( substr( l_col, -2, 1 ) ) - 64 ) * 26, 0 )
         + nvl( ( ascii( substr( l_col, -3, 1 ) ) - 64 ) * 676, 0 );
  end;
  --
  procedure add_member( p_name varchar2, p_row pls_integer, p_first pls_integer )
  is
  begin
     apex_collection.add_member
       ( p_name
       , p_c001 => l_col_mem(  1 )
       , p_c002 => l_col_mem(  2 )
       , p_c003 => l_col_mem(  3 )
       , p_c004 => l_col_mem(  4 )
       , p_c005 => l_col_mem(  5 )
       , p_c006 => l_col_mem(  6 )
       , p_c007 => l_col_mem(  7 )
       , p_c008 => l_col_mem(  8 )
       , p_c009 => l_col_mem(  9 )
       , p_c010 => l_col_mem( 10 )
       , p_c011 => l_col_mem( 11 )
       , p_c012 => l_col_mem( 12 )
       , p_c013 => l_col_mem( 13 )
       , p_c014 => l_col_mem( 14 )
       , p_c015 => l_col_mem( 15 )
       , p_c016 => l_col_mem( 16 )
       , p_c017 => l_col_mem( 17 )
       , p_c018 => l_col_mem( 18 )
       , p_c019 => l_col_mem( 19 )
       , p_c020 => l_col_mem( 20 )
       , p_c021 => l_col_mem( 21 )
       , p_c022 => l_col_mem( 22 )
       , p_c023 => l_col_mem( 23 )
       , p_c024 => l_col_mem( 24 )
       , p_c025 => l_col_mem( 25 )
       , p_c026 => l_col_mem( 26 )
       , p_c027 => l_col_mem( 27 )
       , p_c028 => l_col_mem( 28 )
       , p_c029 => l_col_mem( 29 )
       , p_c030 => l_col_mem( 30 )
       , p_c031 => l_col_mem( 31 )
       , p_c032 => l_col_mem( 32 )
       , p_c033 => l_col_mem( 33 )
       , p_c034 => l_col_mem( 34 )
       , p_c035 => l_col_mem( 35 )
       , p_c036 => l_col_mem( 36 )
       , p_c037 => l_col_mem( 37 )
       , p_c038 => l_col_mem( 38 )
       , p_c039 => l_col_mem( 39 )
       , p_c040 => l_col_mem( 40 )
       , p_c041 => l_col_mem( 41 )
       , p_c042 => l_col_mem( 42 )
       , p_c043 => l_col_mem( 43 )
       , p_c044 => l_col_mem( 44 )
       , p_c045 => l_col_mem( 45 )
       , p_c046 => l_col_mem( 46 )
       , p_c047 => l_col_mem( 47 )
       , p_c048 => l_col_mem( 48 )
       , p_c049 => l_col_mem( 49 )
       , p_c050 => l_col_mem( 50 )
       , p_n001 => p_row
       , p_n002 => p_first
       );
  end;
  --
  procedure read
    ( p_xlsx   blob
    , p_sheets varchar2
    , p_50     boolean
    , p_round  boolean
    )
  is
    l_empty          boolean;
    l_cnt            pls_integer;
    l_col_cnt        pls_integer := 0;
    l_col_nr         pls_integer;
    l_col_block      pls_integer;
    l_prev_col_block pls_integer;
    l_row_nr         pls_integer;
    l_prev_row_nr    pls_integer;
    l_max_col_block  pls_integer;
    l_nr             number;
    l_tmp            varchar2(32767);
    l_name           varchar2(32767);
    l_dimension      varchar2(3999);
    l_workbook       blob;
    l_workbook_rels  blob;
    l_shared_strings blob;
    l_file           blob;
    l_csid_utf8      integer := nls_charset_id( 'AL32UTF8' );
    l_cfh            tp_cfh;
    type tp_strings     is table of varchar2(32767);
    type tp_string_lens is table of varchar2(32767);
    type tp_boolean_tab is table of boolean index by pls_integer;
    l_strings      tp_strings;
    l_string_lens  tp_string_lens;
    l_quote_prefix tp_boolean_tab;
    l_date_styles  tp_boolean_tab;
    l_time_styles  tp_boolean_tab;
  begin
    l_cnt := get_count( p_xlsx );
    for i in 1 .. l_cnt
    loop
      exit when not get_central_file_header( p_xlsx, null, i, null, l_cfh );
      l_name := lower( utl_raw.cast_to_varchar2( l_cfh.name1 ) );
      if    l_name like '%workbook.xml'      then
        l_workbook      := parse_file( p_xlsx, l_cfh );
      elsif l_name like '%workbook.xml.rels' then
        l_workbook_rels := parse_file( p_xlsx, l_cfh );
      elsif l_name like '%sharedstrings.xml' then
        l_shared_strings := parse_file( p_xlsx, l_cfh );
        select xt1.txt
             , xt1.len
        bulk collect into l_strings, l_string_lens
        from xmltable( xmlnamespaces( default 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
                                    , 'http://purl.oclc.org/ooxml/spreadsheetml/main' as "x" )
                     , '( /sst/si, /x:sst/x:si )'
                       passing xmltype( xmldata => l_shared_strings, csid=> l_csid_utf8 )
                       columns txt varchar2(4000 char) path 'substring( string-join(.//*:t/text(), "" ), 1, 3900 )'
                             , len integer             path 'string-length( string-join(.//*:t/text(), "" ) )'
                     ) xt1;
      elsif l_name like '%styles.xml' then
        l_file := parse_file( p_xlsx, l_cfh );
        for r_n in ( select xt2.seq - 1 seq
                          , xt2.id
                          , xt2.quoteprefix
                          , lower( xt3.format ) format
                     from xmltable( xmlnamespaces( default 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
                                                 , 'http://purl.oclc.org/ooxml/spreadsheetml/main' as "x" )
                                  , '( /styleSheet, /x:styleSheet )'
                                    passing xmltype( xmldata => l_file, csid=> nls_charset_id( 'AL32UTF8' ) )
                                      columns cellxfs xmltype path '( cellXfs, x:cellXfs )'
                                            , numfmts xmltype path '( numFmts, x:numFmts )'
                                  ) xt1
                     cross join
                          xmltable( '/*:cellXfs/*:xf'
                                    passing xt1.cellxfs
                                      columns seq for ordinality
                                            , id          integer        path '@numFmtId'
                                            , quoteprefix varchar2(4000) path '@quotePrefix'
                                  ) xt2
                     left join
                          xmltable( '/*:numFmts/*:numFmt'
                                    passing xt1.numfmts
                                    columns id     integer        path '@numFmtId'
                                          , format varchar2(4000) path '@formatCode'
                                  ) xt3
                     on xt3.id = xt2.id
                   )
        loop
          if    r_n.id between 14 and 17
             or instr( r_n.format, 'd' ) > 0
             or instr( r_n.format, 'y' ) > 0
          then
            l_date_styles( r_n.seq ) := null;
          elsif r_n.id between 18 and 22
             or r_n.id between 45 and 47
             or instr( r_n.format, 'h' ) > 0
             or instr( r_n.format, 'm' ) > 0
          then
            l_time_styles( r_n.seq ) := null;
          elsif r_n.quoteprefix in ( '1', 'true' )
          then
            l_quote_prefix( r_n.seq ) := null;
          end if;
        end loop;
        dbms_lob.freetemporary( l_file );
      end if;
    end loop;
    if l_workbook is null or l_workbook_rels is null
    then
      l_log := 'No xlsx file' || chr(10);
      return;
    end if;
    l_log := 'parse_xlsx.prc version 1.000';
    --
    for r_x in ( select xt1.d1904
                      , xt2.seq
                      , xt2.name
                      , xt3.target
                 from xmltable( xmlnamespaces( default 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
                                                     , 'http://purl.oclc.org/ooxml/spreadsheetml/main' as "x" )
                              , '( /workbook, /x:workbook )'
                                passing xmltype( xmldata => l_workbook, csid=> nls_charset_id( 'AL32UTF8' ) )
                                columns d1904  varchar2( 4000 ) path '*:workbookPr/@date1904'
                                      , sheets xmltype path '*:sheets'
                              ) xt1
                 cross join
                      xmltable( '*:sheets/*:sheet'
                                passing xt1.sheets
                                columns seq for ordinality
                                      , name    varchar2( 4000 ) path '@name'
                                      , sheetid varchar2( 4000 ) path '@sheetId'
                                      , rid     varchar2( 4000 ) path '@*:id[ namespace-uri(.) =
                                                                         ( "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                                                                         , "http://purl.oclc.org/ooxml/officeDocument/relationships"
                                                                         ) ]'
                                      , state   varchar2( 4000 ) path '@state' ) xt2
                 join
                      xmltable( xmlnamespaces( default 'http://schemas.openxmlformats.org/package/2006/relationships' )
                              , '/Relationships/Relationship'
                                passing xmltype( xmldata => l_workbook_rels, csid=> nls_charset_id( 'AL32UTF8' ) )
                                columns type    varchar2( 4000 ) path '@Type'
                                      , target  varchar2( 4000 ) path '@Target'
                                      , id      varchar2( 4000 ) path '@Id' ) xt3
                 on xt3.id = xt2.rid
                 order by xt2.sheetid
               )
    loop
      l_log := l_log || ( 'found sheet: ' || r_x.seq || ', ' || r_x.name || chr(10) );
      if ( p_sheets is null
         or instr( ':' || p_sheets || ':', ':' || r_x.seq || ':' ) > 0
         or instr( ':' || p_sheets || ':', ':' || r_x.name || ':' ) > 0
         )
      then
        l_log := l_log || ( 'load sheet: ' || r_x.seq || ', ' || r_x.name || chr(10) );
        l_col_cnt := l_col_cnt + 1;
        apex_collection.create_collection( l_collection_base || nullif( l_col_cnt, 1 ), 'YES' );
        for i in 1 .. l_cnt
        loop
          exit when not get_central_file_header( p_xlsx, null, i, null, l_cfh );
          if utl_raw.cast_to_varchar2( l_cfh.name1 ) like '%' || r_x.target
          then
            l_empty := true;
            l_prev_row_nr := 1;
            l_prev_col_block := 0; 
            l_col_mem := tp_col_mem();
            l_col_mem.extend( 50 );
            l_file := parse_file( p_xlsx, l_cfh );
            --
            if p_50
            then
              select xmlcast( xmlquery( '/*:worksheet/*:dimension/@ref'
                                        passing xmltype( xmldata => l_file, csid=> l_csid_utf8 ) returning content
                                      ) as varchar2(100)
                            )
              into l_dimension
              from dual;
              if l_dimension is not null
                 and instr( l_dimension, ':' ) > 0
              then
                l_max_col_block := col_alfan( substr( l_dimension, instr( l_dimension, ':' ) + 1 ) ); 
                l_max_col_block := trunc( ( l_max_col_block - 1 ) / 50 );
              end if;
            end if;
            --
            for r_c in ( select *
                         from xmltable( xmlnamespaces( default 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'
                                                     , 'http://purl.oclc.org/ooxml/spreadsheetml/main' as "x" )
                                      , '( /worksheet/sheetData/row/c, /x:worksheet/x:sheetData/x:row/x:c )'
                                        passing xmltype( xmldata => l_file, csid=> l_csid_utf8 )
                                        columns v varchar2(4000) path '*:v'
                                              , f varchar2(4000) path '*:f'
                                              , t varchar2(4000) path '@t'
                                              , r varchar2(32)   path '@r'
                                              , s integer        path '@s'
                                              , rw integer       path './../@r'
                                              , txt varchar2(4000 char) path 'substring( string-join(.//*:t/text(), "" ), 1, 3900 )'
                                              , len integer             path 'string-length( string-join(.//*:t/text(), "" ) )'
                                      )
                       )
            loop
              if r_c.r is null
              then
                if l_row_nr = r_c.rw
                then
                  l_col_nr := l_col_nr + 1;
                else
                  l_col_nr := 1;
                end if;
              else
                l_col_nr := col_alfan( r_c.r );
              end if;
              l_col_block := trunc( ( l_col_nr - 1 ) / 50 );
              l_row_nr := coalesce( r_c.rw, l_row_nr + 1 );
              if     p_50 
                 and l_row_nr = l_prev_row_nr
                 and l_col_block > l_prev_col_block
              then
                add_member( l_collection_base || nullif( l_col_cnt, 1 ), l_prev_row_nr, l_prev_col_block * 50 + 1 );
                if not l_empty
                then
                  l_col_mem := tp_col_mem();
                  l_col_mem.extend( 50 );
                  l_empty := true;
                end if;
                for j in l_prev_col_block + 1 .. l_col_block - 1
                loop
                  add_member( l_collection_base || nullif( l_col_cnt, 1 ), l_prev_row_nr, j * 50 + 1 );
                end loop;
              end if;
              if l_row_nr > l_prev_row_nr
              then
                add_member( l_collection_base || nullif( l_col_cnt, 1 ), l_prev_row_nr, l_prev_col_block * 50 + 1 );
                if not l_empty
                then
                  l_col_mem := tp_col_mem();
                  l_col_mem.extend( 50 );
                  l_empty := true;
                end if;
                if l_max_col_block > 0
                then
                  for j in l_prev_col_block + 1 .. l_max_col_block
                  loop
                    add_member( l_collection_base || nullif( l_col_cnt, 1 ), l_prev_row_nr, j * 50 + 1 );
                  end loop;
                end if;
                for i in l_prev_row_nr + 1 .. l_row_nr - 1
                loop
                  add_member( l_collection_base || nullif( l_col_cnt, 1 ), i, 1 );
                  if l_max_col_block > 0
                  then
                    for j in 1 .. l_max_col_block
                    loop
                      add_member( l_collection_base || nullif( l_col_cnt, 1 ), i, j * 50 + 1 );
                    end loop;
                  end if;
                end loop;
              end if;
              --
              if p_50 or l_col_block = 0
              then
                l_empty := false;
                if r_c.t = 's'
                then
                  if r_c.v is not null
                  then
                    l_tmp := l_strings( to_number( r_c.v ) + 1 );
                    if l_string_lens( to_number( r_c.v ) + 1 ) > 3900
                    then
                      select substr( xt1.txt, 1, l_varchar2_sz )
                      into l_tmp
                      from xmltable( '/*:sst/*:si[$i]'
                                     passing xmltype( xmldata => l_shared_strings, csid=> l_csid_utf8 )
                                           , to_number( r_c.v ) + 1 as "i"
                                     columns txt clob path 'string-join(.//*:t/text(), "" )'
                                   ) xt1;
                    end if;
                    if l_quote_prefix.exists( r_c.s ) and length( l_tmp ) < l_varchar2_sz
                    then
                      l_tmp := '''' || l_tmp;
                    end if;
                  end if;
                elsif r_c.t = 'n' or r_c.t is null
                then
                  l_nr := to_number( r_c.v
                                   , case when instr( upper( r_c.v ), 'E' ) = 0
                                       then translate( r_c.v, '.012345678,-+', 'D999999999' )
                                       else translate( substr( r_c.v, 1, instr( upper( r_c.v ) , 'E' ) - 1 ), '.012345678,-+', 'D999999999' ) || 'EEEE'
                                     end
                                   , 'NLS_NUMERIC_CHARACTERS=.,'
                                   );
                  if l_date_styles.exists( r_c.s )
                  then
                    if lower( r_x.d1904 ) in ( 'true', '1' )
                    then
                      l_tmp := to_char( date '1904-01-01' + l_nr, 'yyyy-mm-dd hh24:mi:ss' );
                    else
                      l_tmp := to_char( date '1900-03-01' + ( l_nr - case when l_nr < 61 then 60 else 61 end ), 'yyyy-mm-dd hh24:mi:ss' );
                    end if;
                  elsif l_time_styles.exists( r_c.s )
                  then
                    l_tmp := to_char( numtodsinterval( l_nr, 'day' ) );
                  else
                    if p_round
                    then
                      l_nr := round( l_nr, 14 - substr( to_char( l_nr, 'TME' ), -3 ) );
                    end if;
                    l_tmp := l_nr;
                  end if;
                elsif r_c.t = 'd'
                then
                  l_tmp := to_char( cast( to_timestamp_tz( r_c.v, 'yyyy-mm-dd"T"hh24:mi:ss.ffTZH:TZM' ) as date ), 'yyyy-mm-dd hh24:mi:ss' );
                elsif r_c.t = 'inlineStr'
                then
                  l_tmp := r_c.txt;
                  if     r_c.len > 3900
                     and r_c.r is not null
                  then
                    select substr( xt1.txt, 1, l_varchar2_sz )
                    into l_tmp
                    from xmltable( '/*:worksheet/*:sheetData/*:row/*:c[@r=$r]'
                                   passing xmltype( xmldata => l_file, csid=> l_csid_utf8 )
                                         , r_c.r as "r"
                                   columns txt clob path 'string-join(.//*:t/text(), "" )'
                                 ) xt1;
                  end if;
                elsif r_c.t in ( 'str', 'e' )
                then
                  l_tmp := r_c.v;
                elsif r_c.t = 'b'
                then
                  l_tmp := case r_c.v
                             when '1' then 'TRUE'
                             when '0' then 'FALSE'
                             else r_c.v
                           end;
                end if;
                l_col_mem( l_col_nr - l_col_block * 50 ) := substr( l_tmp, 1, l_varchar2_sz );
              end if;
              --
              l_prev_row_nr := l_row_nr;
              l_prev_col_block := l_col_block;
            end loop;
            if not l_empty
            then
              add_member( l_collection_base || nullif( l_col_cnt, 1 ), l_prev_row_nr, l_col_block * 50 + 1 );
            end if;
            l_log := l_log || ( 'rows: ' || case when l_empty and l_prev_row_nr = 1 then 0 else l_prev_row_nr end || chr(10) );
            dbms_lob.freetemporary( l_file );
            exit;
          end if;
        end loop;
        apex_collection.add_member( l_collection_base || '_$MAP'
                                  , p_c001 => r_x.name
                                  , p_c002 => l_collection_base || nullif( l_col_cnt, 1 )
                                  , p_c003 => l_prev_row_nr || ' rows'
                                  , p_n001 => l_col_cnt
                                  , p_n002 => l_prev_row_nr
                                  );
      end if;
    end loop;
    --
    dbms_lob.freetemporary( l_workbook );
    dbms_lob.freetemporary( l_workbook_rels );
    if l_strings is not null
    then
      l_strings.delete;
      l_string_lens.delete;
      dbms_lob.freetemporary( l_shared_strings );
    end if;
    l_date_styles.delete;
    l_time_styles.delete;
    l_quote_prefix.delete;
  end;
begin
  l_collection_base := :p1;
  l_varchar2_sz := case when :p2 then 32767 else 4000 end;
  read( :p3, :p4, :p5, :p6 );
  :p7 := l_log;
end;
