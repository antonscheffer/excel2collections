set define off
set verify off
set serveroutput on size 1000000
set feedback off
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK
begin wwv_flow.g_import_in_progress := true; end; 
/
 
--       AAAA       PPPPP   EEEEEE  XX      XX
--      AA  AA      PP  PP  EE       XX    XX
--     AA    AA     PP  PP  EE        XX  XX
--    AAAAAAAAAA    PPPPP   EEEE       XXXX
--   AA        AA   PP      EE        XX  XX
--  AA          AA  PP      EE       XX    XX
--  AA          AA  PP      EEEEEE  XX      XX
prompt  Set Credentials...
 
begin
 
  -- Assumes you are running the script connected to SQL*Plus as the Oracle user APEX_040000 or as the owner (parsing schema) of the application.
  wwv_flow_api.set_security_group_id(p_security_group_id=>nvl(wwv_flow_application_install.get_workspace_id,1240203129055874));
 
end;
/

begin wwv_flow.g_import_in_progress := true; end;
/
begin 

select value into wwv_flow_api.g_nls_numeric_chars from nls_session_parameters where parameter='NLS_NUMERIC_CHARACTERS';

end;

/
begin execute immediate 'alter session set nls_numeric_characters=''.,''';

end;

/
begin wwv_flow.g_browser_language := 'en'; end;
/
prompt  Check Compatibility...
 
begin
 
-- This date identifies the minimum version required to import this file.
wwv_flow_api.set_version(p_version_yyyy_mm_dd=>'2010.05.13');
 
end;
/

prompt  Set Application ID...
 
begin
 
   -- SET APPLICATION ID
   wwv_flow.g_flow_id := nvl(wwv_flow_application_install.get_application_id,101);
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
 
end;
/

prompt  ...plugins
--
--application/shared_components/plugins/process_type/nl_amis_scheffer_process_excel2collection
 
begin
 
wwv_flow_api.create_plugin (
  p_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_type => 'PROCESS TYPE'
 ,p_name => 'NL.AMIS.SCHEFFER.PROCESS.EXCEL2COLLECTION'
 ,p_display_name => 'Excel2Collection'
 ,p_image_prefix => '#PLUGIN_PREFIX#'
 ,p_plsql_code => 
'function parse_excel'||chr(10)||
'  ( p_process apex_plugin.t_process'||chr(10)||
'  , p_plugin apex_plugin.t_plugin'||chr(10)||
'  )'||chr(10)||
'return apex_plugin.t_process_exec_result'||chr(10)||
'is'||chr(10)||
'  t_file_id number;'||chr(10)||
'  t_document blob;'||chr(10)||
'  t_filename varchar2(32767);'||chr(10)||
'  t_collection_name varchar2(32767);'||chr(10)||
'  type tp_fields is table of varchar2(32767) index by pls_integer;'||chr(10)||
'  type tp_lines is table of tp_fields index by pls_integer;'||chr(10)||
'  t_lines tp_lines;'||chr(10)||
'  e_no_d'||
'oc exception;'||chr(10)||
'  t_rv apex_plugin.t_process_exec_result;'||chr(10)||
'--'||chr(10)||
'  t_as anydataset;'||chr(10)||
'  t_as2 anydataset;'||chr(10)||
'  t_as3 anydataset;'||chr(10)||
'  t_as4 anydataset;'||chr(10)||
'  t_as5 anydataset;'||chr(10)||
'  t_dummy pls_integer;'||chr(10)||
'  t_parse varchar2(32767);'||chr(10)||
'--'||chr(10)||
'  t_parse_csv varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC8VYbW/bNhD+nl9B9Isl1DFsF1uHeAmQucFWYEuGJAi2TwItnW11'' ||'||chr(10)||
'    ''siiQVOIM/fE7vkmkLL+06zAjsaXj8fjweM/xyLMM0oJyOCNEvlZAZJUscygyQXJB'' ||'||chr(10)||
'    ''JF0'||
'UQNiSPFOerimfRu+m779/H5O8zGBLFq+kKkSSlxJWwGeeiSIvIbTg2T3SN6OS'' ||'||chr(10)||
'    ''drtae/t6mj627+zs/ByFy7pMZc5KkrJiSkVEnJXGXIxaHGTNS0LLV9VVgERZLvBL'' ||'||chr(10)||
'    ''WaVSNShcMycRnqoSLmCVl7rRao60JOVAJUQkW2xEosRipL5TlkGi5zU05uPGsBw9'' ||'||chr(10)||
'    ''gPxYLllEyroohke+P/z020Py+OfvNw8j9T2/+3CTPF3fz3+5vp8OyTgwDGVm8Vhp'' ||'||chr(10)||
'    ''vnTOGKWsLiW5ImOjvgYzmX83nf9wQvumRLx1+SLMQ7OqjZkl4yTHSCMTMho1biqo'' ||'||chr(10)||
'    ''kFahYKyyjyYiRjTL8lJIWqYwC1uqHFJ4y'||
'YUHM/A+bHMhRZTHiD5zUnztLEtnaRzM'' ||'||chr(10)||
'    ''Tw3M78ZeUwCwgYJ+eXIkJim6ibygRX9MC+ZTrMfyWpQIHU68ORAtUCO1MiXJlzNy'' ||'||chr(10)||
'    ''tn/cwQDdzWtoTXXN6D47q2tN62fLWKWoBNiEQ2rGV5ylkNUc0OJK8X0jVk3m0mzX'' ||'||chr(10)||
'    ''zDaUPT/XQVPBNslgUa+SDQhBVzACzhl3ve34PWo4hHsOlBWeLpyKcgFJKp61MaWe'' ||'||chr(10)||
'    ''sbTeAC7xomALLR2iVEDV4r24JIPZoGmDMi2YgCxUeBMoMIzDVaCguKU1mtkrFyMS'' ||'||chr(10)||
'    ''gtYWLkdkIGTClktcK9QyeVX1njgFwdOmvVdBTQPN5pl6LevNwrSnjBYgUvRQiRl'||
'b'' ||'||chr(10)||
'    ''oUITSZ5FPt44CNa9n+GOjVoWST75oRxtaOUafMvDVuPnm9ub+4/zZH53+3jzx6PX'' ||'||chr(10)||
'    ''8vH69jp5vEvu7q/nv96Q+OvhDFSuSuYPg1NNNDm6oOUqSRn6dSs97+nMhY4dZbCk'' ||'||chr(10)||
'    ''deH05Nb1e6G8VB7UH28/VG3AinbXnjZD+SEWTWIdI89FRES9EFKHPWoMyQT/SDxU'' ||'||chr(10)||
'    ''EdjC3AnBfgNOzbPyxrNSqNwS7t9KXDHRJ8a0yuUefT3HniaVt5K07O2maxAUZvs6'' ||'||chr(10)||
'    ''tvWBTT2KLcmS1ZLANoVKlRThxq+TzUBxXK3F/OGJvORyTZSHaCpBxQcZkM+fg4Ap'' ||'||chr(10)||
'    ''6QZZ4RMndi5qlt3kQAm'||
'binHKXyPD3DCDtsqsfAYuJVPEtqoHwnDoJaGDas0A+L+h'' ||'||chr(10)||
'    ''W5H/DQf1g2xyRLNNK0cUGy8d0fOJdETVcueAVmzzuN6x1QbPmxVI1zyavIvVourH'' ||'||chr(10)||
'    ''MS5eXxFlaKgS4U4HG12FgF7dcWfns0gMfVAJf1ZybQG15DJ08TNzQwZf2LKglXpl'' ||'||chr(10)||
'    ''A1YC0pQHzuKVGdnt0ugQx3cXk0ZRE55cesnCzc4vXyzTIh9eHAW4dGIZDPx6qpmb'' ||'||chr(10)||
'    ''e3zroHfgG3WVUFA5XDjpZSdnJihrcGam6yXxa6pO9YVVCMWqzksO3dLIVSv7/aUG'' ||'||chr(10)||
'    ''eWtTZJ/Heoc91XMn6WEw7ltFA+/cd3Xop86CmMlMAy+0of3/Y'||
'u/gPmktcBMMsXcX'' ||'||chr(10)||
'    ''4vj8jU7ANP81CF7rr4PQWsarPBG7oGHFVwCd4H/H3i50P3N4bzvA9yWUcGJm6B9N'' ||'||chr(10)||
'    ''HjkG+RC7TGQRrN9B3QdgMVKSNW6xC1BHsAx/OeR/ddN/nxM6VndYaxLhIWZ3Ty9B'' ||'||chr(10)||
'    ''zO9NQbrC6onOtqjpy1us6O3kJyx9imytXHaOj1/is1PJ2k/CzlEx8KIJh8iivvJR'' ||'||chr(10)||
'    ''6/Bw6GOCR9z9k/lmWI8kjGOBcyrFO+nwm2DWjjkRt9Y9yPpTGb+f7SE9/LeQKE1N'' ||'||chr(10)||
'    ''ueSwU9+2xYy6zonsr7kRieJgi2jO264Ybw7aEbnQ9e1Q/Wq+XZiDiXvAUdRFxcV2'' ||'||chr(10)||
'    ''Ys6p5'||
'oqwvRexo9o7kbG9E7GYxs19iBr9H0tvidFCFQAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xml varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC81XbW/bNhD+nl9B5IvtTVZsJ10HB3vJ0hYr0GJD4nXbJ0GmTjYb'' ||'||chr(10)||
'    ''SRREKnGA/vjdUZREKk7jbOswAlHkI++5473rKAGexRUcMaajRPI6h0KzdSbX50S6'' ||'||chr(10)||
'    ''L4HpMkoFZIliQjEdrzNgMmW3ccW3cbUYny5efvNywkSRwI6t71mZqUgUGjZQuRCZ'' ||'||chr(10)||
'    ''KMBHcHCf4E1iHQ9ZLd5jnA2P5T0/mk6RmNYF10IWjMtsEasxa1E6uAmeqkDXVcHi'' ||'||chr(10)||
'    ''4p5YFWikCYUPQo01bZBe5'||
'y1FOUeJuIaNKMymPRkaCq8g1jBmyTpXEZFVSE8uE4jM'' ||'||chr(10)||
'    ''vYIGftIB6/Aa9NsilWNW1FkWPPF89dP762j156+vr0N6Xv7y6nX04eLq8ueLq0XA'' ||'||chr(10)||
'    ''Zh4wFInVx1JF2hoj5LLGCPiezZrjW2gu88+u8wUv9NiVmOOXZ+kcNF7tYFJZMYGR'' ||'||chr(10)||
'    ''xuYsDDszZbHS9kAmZWlfm4gI4yQRhdJxweHc3ykFcLgTylHTsz7shNJqLCaofdJS'' ||'||chr(10)||
'    ''8efALQPXtGp+7NR8MXO2PAU7VdAuH9okZhzNxO4Q0ZVplfk4MbKcHSKhwZlzB2YI'' ||'||chr(10)||
'    ''JKmnEUWk5+zocbmjEZq7qqGHGsIYngfetdDm3WYsHSQCbqFIk/F'||
'lJTkkdQWIuKF8'' ||'||chr(10)||
'    ''z9Wmq1wm201mNyk7nZqgKWEXJbCuN1EOSsUbCKGqZNVyW/l7jqGI9t07TPoM1Snj'' ||'||chr(10)||
'    ''SkG0yzMDRse92muoAVLVFkAXlVve2PI7kyDmTHcFshNxRlyJhH4Wdb62h5GXLox2'' ||'||chr(10)||
'    ''j0SCJr94d7r4bfXm2xHqx/DWfAv8BtXERBDFhkLoj/fv2A+4LDDqyfDPLXt+4Wyp'' ||'||chr(10)||
'    ''e9Rttyp5t4+MpXgfGfMWojTXfZuZz2YTus0oSaZ5Pr3HxbbbxdkyF0ulRn7lNd4e'' ||'||chr(10)||
'    ''kZHpQnSbO6G3jJBiroFMwUbs0yfPNkWco+NcM076okkmQOnWCq7DAp9laApkmjU0'' ||'||chr(10)||
'    ''StAK6Zo'||
'sPGYKMuCafeUlZpvLlcyNLKpKY3oj5VQZc0w/lkAa1xneAKN+qdB7eaym'' ||'||chr(10)||
'    ''ueCVVDLVUy7zpUxTwWGpSkyaxKgyMrHy+RWw0cnvsrpZS3ljXixnGStjSN1F7OfW'' ||'||chr(10)||
'    ''HjkT65WuDNkAChM0goY+1R2r9T++ZvP2hKmULR0nAkoEhnbtiQ5ji+rWySYQEX7e'' ||'||chr(10)||
'    ''l6nGMUR/0jFfyjlPGnXPCp4bANjUjpU6/juyno4dq1EfNicrss/JlbzrA8iEP7ay'' ||'||chr(10)||
'    ''rM6L6DbOajhQmYbFzHttZStjzOjRj0ot39IQ+DwTBozzNpktUjhiB0E8YoqePOi2'' ||'||chr(10)||
'    ''TY3zI66NOQ7ZYTH3/4m6/zbuDo28JvYw1k4uI'||
'cvcgMO0Djk/WPa/HWikmC7ZoI81'' ||'||chr(10)||
'    ''kIj4CufTE4JeYSAeGIAuNOYQ49h8fMSDgR41rrvxYHrEImxCN8SLYUNGibASOfiG'' ||'||chr(10)||
'    ''GUyntBomUpnKuzSNd0wviRnLu210JbV3avNJcrw67tt8eDybzY6xlQXujOBNof5o'' ||'||chr(10)||
'    ''2GljR1dT/idjk5NmnOiEDs/bpC1us1YzDInAbkzcntTK9Gdfp9VYDIpEi0EbA4yH'' ||'||chr(10)||
'    ''CM037Nj+bz4AxjiSNM3Rmbv6QdtdR0PUdg5tx6RuBh2zpRlnAvqPLXRiJvblbk6S'' ||'||chr(10)||
'    ''2m/l/gPB6mM/Dmb248BqO3M+DJa7xSEIcx9h7iGcHoKw8BEWHsLZIQinPsKph/Di'' |'||
'|'||chr(10)||
'    ''EIQzH+GsQyCz/wVgR2EPZhEAAA=='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xlsx varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC+1a64/bNhL/nr+CV+BgueuH/Ih3s3tbNNkkuACXNsimxRV3B0OW'' ||'||chr(10)||
'    ''aFsNJRkivWv3r+8MSVGkHrY216D34ZTAa1Pkj/Oe0VDPIhqyIKfPCBHHHSVit1zH'' ||'||chr(10)||
'    ''lEWcxJyIYMUoydbkIcjDbZBPvdn0cnHZJ3Ea0QNZHcmO8WWcCrqh+Y0FweKUuggW'' ||'||chr(10)||
'    ''7pm1USCC6lKN17ZSrdFrb54NhzC43qehiLOUhBmbBtwjBYqB68OsnIp9npIgPeJS'' ||'||chr(10)||
'    ''TgWMxRw+EDUQeAPpuilGuDUV'||
'B1d0E6fypp45kiNhTgNBPRKtEr7EYT7CzzCL6FLy'' ||'||chr(10)||
'    ''NVDwfQMsRvdUvEvXmUfSPWODM5+vX72/X3765cOb+xF+3v34+s3y55cf7/7+8uN0'' ||'||chr(10)||
'    ''QHwHmKaRpkePxutCGKMw26eCfEd8NX1LFTP/HTtfkaE2loillyfRPFBaNTDrLCcx'' ||'||chr(10)||
'    ''WBqZkNHIiIkFXOgJLMt2+quyiFEQRXHKRZCG9Ma9s4tpSB9jbpHpSJ8eYi64F/eB'' ||'||chr(10)||
'    ''+qgYhZ8VtVRUU5D5qyHzuW/dcgg0pIBcfi6cmIQgJvIIiPaemphf+3Iv6w4OgcCJ'' ||'||chr(10)||
'    ''xQORA7hTOYYj8fqGPGvft9cDced7WkJVYeSamnY1tPyuPRYn4gDcgi'||
'2lx+/yLKTR'' ||'||chr(10)||
'    ''PqdkF+ScLg+MH+QS9P0oC/cJBaGuWLaSowMY5VtKRZrbAUXe69thAMyKTl74c7LK'' ||'||chr(10)||
'    ''MkaDtHAtkezIIWF2fJB4lUEd1tJ9sk7EMq5EVmvn1viGyIe1jeDg3Vh0nptUxljq'' ||'||chr(10)||
'    ''kKFZO0eCXKfXF8N6j4ZbejMu8jjdfFlCkULV60uo4s5DwKpIxS031uucYGUFNIMp'' ||'||chr(10)||
'    ''kI62gd/lAJoEoygFSQD+3GW8+CmtwhggrF1pa9GWUuYCM2kv2DIPHkfgcGAv2XIV'' ||'||chr(10)||
'    ''p0F+LBjUwQk2HvH9CngriNF0FPv3BwaIxUIwugSrj0FbpXvUGXRmSuB4o4lG3NVR'' ||'||chr(10)||
'    ''gHxs67u+JX'||
'OXRdiwI38F+Q6/6zxLahxLOlr5GZBJSdwp7iCpLwO2VpzBD2MGLgdV'' ||'||chr(10)||
'    ''v27nJOBhHHuk1AOADshwQvrwb0gWczukXpD0gXkQV1pWQcYqF8Kfb8l0IZPYU0Bm'' ||'||chr(10)||
'    ''NZDF5cJKhY1y2VCQe8yo3gjRfot3OxqVRq5voZxx5jINEmrEp286QjSLtPSK2Ifj'' ||'||chr(10)||
'    ''ZdyOMUbbjouD26h5fM2ax2kK+Rk8vPTqiW9lfss3b2qKVCSAFRunAmHAio3YVsWA'' ||'||chr(10)||
'    ''Mp1OClwnYUIWFCo1Kry/gRIg1zY4qgU4IPOBnt8nt2RLDyID64aE99yfv/Kf+4se'' ||'||chr(10)||
'    ''aI0Mh+QNTIHwF0ImyiF4RXFOQ5h7JDzepAGImxpK'||
'DD/qy5BM6klTq18WFZreW1M0'' ||'||chr(10)||
'    ''OCWDiVqM2TCYVQ2I0RdsasfHZk4vyGQB7F6UdLm1UyvCtES4Mi7hKAG4KQLEKoZM'' ||'||chr(10)||
'    ''n0aNodJBnQxK+i/IC4wllh78q570pdvaYFuFZRkjiKP38h+z6U+f3l71pBr3Yn1V'' ||'||chr(10)||
'    ''mgzjtH3hT/dXH+7ms0u18N2r9wRL0F2woQRGq9WTWyWW/nkrBRJPrtIR0I6pBN3D'' ||'||chr(10)||
'    ''KfMq1zmJnVpbuwZntGnkPr1yg1wHZGv1fPGktSd3GliKODXvhAFguDnrCiXrc+3j'' ||'||chr(10)||
'    ''EIuzZJdTzin4qQxAFqz0VES+JXbVXtlcziv1ZgxBpyTwMbDfMZTTvX/3KnKQ1TvS'' ||'||chr(10)||
' '||
'   ''YYLLeJ2xiFatpSEiqAvtGdfTZCeOxMomlZXyvhSF168gVIy5IdZoFs95tWtdE7/u'' ||'||chr(10)||
'    ''wr6Pno3s0jWD2vOUTE3i6a7V+ZRUmFPJ79ohY/L26hWSYl2zIuRvAB3mBlUNGNbD'' ||'||chr(10)||
'    ''bHf0FGy7oQ66eu+AdDZY/5QHQUSdnLprZHlBZicmXpyJHAZkeqnU+BbsjciYV3Od'' ||'||chr(10)||
'    ''L4Z+oaDfHCDpEtmGOgteUbpRVgC7YDqS6irr2DBLw0Ccz1KuBmQCBcLuPt7Npk8K'' ||'||chr(10)||
'    ''fYUWKlW+iiz981Go63UyxFZkZD0TFFuP2G/LkhAttXoj4atEBt9Ehk9bKsMYPoFy'' ||'||chr(10)||
'    ''uA8C8dKMFGRB3dz/6lGj9HbZ2R'||
'AQPIHQ/Ggsye2LVBf9wSFC2slJ3/+/6xeXaTiB'' ||'||chr(10)||
'    ''8JsMt+23XU2fq3HO8ePUV6SjrDqDznwN2klK3WGnOgNKWsHbZP/NwW14kqmVJfI5'' ||'||chr(10)||
'    ''137UMwlY99k889RrN/qgNDqw8WOWf15l2ecRzO3hM0HKuCydOcW2mGcV9vh8UGV3'' ||'||chr(10)||
'    ''RFEiocBiq4AyXz7k4++L3mCvzZyQjISl/PabrRC76/GYh1uaBHyUQR6BO/DMlAQC'' ||'||chr(10)||
'    ''fuabMYdwFESyh5iw8dT3F+MkiNNvWsFNt8u0KEEqnhERhLs0E1KUDQiBlP0jNmXk'' ||'||chr(10)||
'    ''dHxcVv21h4B5fVNlYmDCQnNSLTQrNHRXChdHRnlHlSh4ThnUsiSO1GP/'||
'nn3GFpAa'' ||'||chr(10)||
'    ''S0VWbZCqpkieJZIcbDp6+A39he+CkEIqgnIx2DNBel+sl0Z5AIeKv3ucPg4pY/9c'' ||'||chr(10)||
'    ''8/Fh3SO7AHINPBW2hHHgZ5+kHHjUbTpYILak9z38epuId1GDGXSWTqU3/D8jH8Ub'' ||'||chr(10)||
'    ''13+/ioz0tsC53VXy/X6xVrFyB0/lTRKWQ49bmlP0LDzoAYcBMGAkitBCv3Oe47AF'' ||'||chr(10)||
'    ''Ys9JkvNzjsf6HK1Zt6VS06M6KJIzrQaK05P36qs8gET/xsQEzl2esZQnMdV9He9q'' ||'||chr(10)||
'    ''21UfECh4mfUsOorzpSqYJqaJCLe794T4Ajqm0b06K3hSmDGuBNrRA03epI8hirbX'' ||'||chr(10)||
'    ''n+ZHXIx53Nlp'||
'gGoSYvtT2b1ojyf0ENId9pP1DNkPzaAwzrlqL8jsjKkd80vAGFQO'' ||'||chr(10)||
'    ''EOlkkc1hv1QA2URL6S9w2Yn8Cbr81x1AwdflJzy//c+TVIkWnC/5Vqg0pvX6bVN8'' ||'||chr(10)||
'    ''+MMUCCs+BxuqVBcq2ofy7Lk5d9ZVKhkd//hA8zyGeHROtS2a3gW5cNr6bsD7ALd/'' ||'||chr(10)||
'    ''gNutdUVpD00zVDA0e7D4MwXKdbElrZeP5Z+/tsZTJ2yos/AIFCTMAbpsfxans1jH'' ||'||chr(10)||
'    ''gMFh3BTZUgV+j+RgXkl5bCJ1PSqoglp0gpbS0zYjnw4NotUgt4+r1entebts3RL3'' ||'||chr(10)||
'    ''6RpoCgvFw6uzFiqn/xlhpuEa6FpYAihFvw5EMM6zx3'||
'FoW6y81QmysNvcOfcpzDU/'' ||'||chr(10)||
'    ''b6c2daIRpCnanQDhjSD8aSAPRZGiLgXy0A2jRRflcOU1D3AYaUsjAYbecwhtai2r'' ||'||chr(10)||
'    ''uQ+tjwi1NcVxu0zrOrJ7BuYCjyrrXeQ2hIaec71jXF1vqOY21fIxxio9iimSonMs'' ||'||chr(10)||
'    ''yV588exUJbY+3ZaBOoDx8IvcuOdPhvBfPgsOeq9fD9+/H/4CVw9PyLSYZMk4TJLh'' ||'||chr(10)||
'    ''ES6y3U7n10l8zTE53FS2apDe2d1nuLtf371U05AsVFTsTEZNLacVqzfqehpgI6i3'' ||'||chr(10)||
'    ''jQhTUV0B5YMiypvfwOl0Nn++uLx6ocJ6H/iz3gboMF+aMBDstm7cl5nUK4W6dg5U'' ||'||chr(10)||
'   '||
' ''weuZxfqdkjozNlBxPl9UseVLSR65lulkgH8hv/XlS1PXhwmiF68rlu9oaRp0/ezr'' ||'||chr(10)||
'    ''97M0hb71btb1YdoFYeIiTByEWReEqYswdRDmXRBmLsLMQXjeBWHuIswNAsr9d94m'' ||'||chr(10)||
'    ''KFvWKgAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xls varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC+0ca1Pjtvb7/gr1w50kS6BxEiDslp3hEVrm7kIH2PbeTxnHUcDd'' ||'||chr(10)||
'    ''xM7YThf66+/RW7LkRx6wtHc97QKydM7ReetI1psJDmZ+gt8glD0tMMoWo2mIZ5MU'' ||'||chr(10)||
'    ''hSnK/PEMo3iK/vST4MFPus1e9/DgsIXCaIIf0fgJLWbpKIwyfI'||
'+T9xqIWRhhE4IG'' ||'||chr(10)||
'    ''t2LsxM/8/FAOr2gkG8PHvn+zuwuN02UUZGEcoSCedf20iQQUCa4FvRKcLZMI+dET'' ||'||chr(10)||
'    ''GZriDNrCFP4hUP2MvCB0vRctqdaVNI7xfRjRl7znHm0JEuxnuIkm43k6Is3pHvk3'' ||'||chr(10)||
'    ''iCd4ROfVZuBbEnC2d4uzy2gaN1G0nM3aFf+en366Hd3999fh7R759+z6fDj67eTm'' ||'||chr(10)||
'    ''7JeTm24bdQzAOJpwenhrOBXM2AviZZShD6jDuj9gNpnNpvOMEyqaEtLkshLNbSZV'' ||'||chr(10)||
'    ''CWYaJygETUMe2tuTbJr5acY7zOJ4wX9lGrHnTyZhlGZ+FOD35ptFiAP8NUw1Mg3u'' ||'||chr(10)||
'    ''48cwzd'||
'Jm2ALqJ6IV/syJJScaQeYfksz9jvbKIFCSAnz5TRgxCoBN6CtA1HFyYv5o'' ||'||chr(10)||
'    ''UVzaG9IEDEfaHBBtIJhUG2kJp+/Rm2K8jQawO1liBSoPho6xpMtB09+5xZKOpAFe'' ||'||chr(10)||
'    ''AUpq8YskDvBkmWC08JMUjx5nzJCJ6U/iYDnHwNPxLB7T1ja0pg8YZ1Gi+xP6rqV7'' ||'||chr(10)||
'    ''ga9x8mUcx1/oUGFWIaFIeSDSNAOm5Zrm/qOrOQA6ck33yTjMUOJ/bXrSdMfhdLqP'' ||'||chr(10)||
'    ''APUM+5FoTLOEdmOOWLRm84WjNcGB3cq9bJpma3l4SgOMZSBMmGB/2ADKaS8F9jhl'' ||'||chr(10)||
'    ''4/h40TydZ652jgkGQQcDlwa6Ch8ZKoFoCPNM'||
'kPKCthEosnrvdTot9O4YNX4fDj7d'' ||'||chr(10)||
'    ''/n555XX3u40ch4lyURkAmfAjTiZcycEj+nOcx8ZftpGmW7wtLzsC2QqvGr4y2bGx'' ||'||chr(10)||
'    ''EorRboCRem1ETR5dtfiafOlGy/kYJ8TOki9E41BLN1X2lkUeZlQqaspO1CXB0Cx+'' ||'||chr(10)||
'    ''wI9NtMxmI/hrD6xiBL5RNaTLMZgAQ9VGHvyHWm3U6PQaqIUED+VDfVyj020wnyaA'' ||'||chr(10)||
'    ''ADKwmRgsLPKTJ8EiB1aGpXFxdkGfBsElOs3CLJvhETigEFS8hX5E/QL0vRdC3+kU'' ||'||chr(10)||
'    ''ENApJ2ASL0GNFP4gjgI/a5KB7Gm0mWiL0Rcg9jZHXIMp5Wzx8mwhIeON/IWrswoe'' '||
'||'||chr(10)||
'    ''EHkmo2A6JpiCKfX6fH5ce4lRPEAnzDzxvtfVkpPxU4ZHYOo4sa2PvMcRZCBhdA9/'' ||'||chr(10)||
'    ''KPvvaADS9C9BqA4Aod1dlOIgg8Cfhn9hrb8cYPd/iJPMPQraLifWKPkeAoroIzr/'' ||'||chr(10)||
'    ''SyXCmivCQZhbKxj9S3wRDZCpnykwGhOg2dle1J9NkYij2+kPdHYSFoxAsTIf3Fei'' ||'||chr(10)||
'    ''BXEeTbE/zzWSiO2kNu+1EfmlJVUIoWB0kWA8usXB5blUN8BNksPMiFAQO3a990RG'' ||'||chr(10)||
'    ''ZAQXURvN/SdE8zCS2oHloGlIEtXxksa6KM5IapMRLkO6ixj1Evcwmoyup6OzB5gp'' ||'||chr(10)||
'    ''p6EQd5fivkv8cEaUkfUGnD'||
'7/NSBAJOTbk7vcpIoh9yjkWyYQIHqZ4gmRP5kNF5M/'' ||'||chr(10)||
'    ''m8Vg5yR4UK2ReD7ZiArx9EvwzMHNQLcidJq8zi9vRsP5InsycLE8jKCBYAQg4E/m'' ||'||chr(10)||
'    ''RVsUKR1ggLglne5xJQhPgPicEvrYqBwkqpGVkLo5SIYmEEAf4+ALqjGrngBEBpyC'' ||'||chr(10)||
'    ''90oNML8m8QInwJ8KMH0BRgwwoNzEoLo1iNkXUOgAnT96yiDdL4ymyzswXy0xCKZt'' ||'||chr(10)||
'    ''BE6ZpgbCeGHR1dQGEmOCZaeKC6AmMoLg6D57aKrOLfQTgefsLLCKzjQlGcCQH4yJ'' ||'||chr(10)||
'    ''nXfOLjxv2DnxTj3vZEjUQIETvxpLPJYW6csksQDKRRnggVrOFZPV'||
'PYL/gS6DrIsh'' ||'||chr(10)||
'    ''i59GjDYjKJ4BbBWD72W7CKKUtwZFx25Qrllq8ZBk0ycfvYPPdxfewcdhQ04dCKjs'' ||'||chr(10)||
'    ''3yhiFA2O0HURfyUZVrddOwmzWdjzKAvb5mxbyAjegG9b6HqF6MCBgY0gmqrUcXiM'' ||'||chr(10)||
'    ''PFna6JCagdc5QrvIc1c1eOh/d7wB/YeHaAfwvUX9Nurb89AKB4+w9KXqKxEfG6FU'' ||'||chr(10)||
'    ''r6qQjKEJYKnrEP2LqwnbmMjBUekEvj5AjFaofjh2huJiPsdlfoxqMHVnwEymzm8V'' ||'||chr(10)||
'    ''rh3dxeUFzHrDsgDErJxXrjokGMp+srpTs8W4uzrHRBpDpU6oq5K8VUTaTGIC/265'' ||'||chr(10)||
'    ''yim0hiGR'||
'Gtx4Gc4mNXIVWX/jrDa4V2pW64ibyegPEEttiXvFEucCfwXyricIksHv'' ||'||chr(10)||
'    ''lotjS4ZeTv/fwdDLxC7k/goEb0pMqSRrqjLUSZhQ/JDsQ4zYqgr0/96+3usOypWA'' ||'||chr(10)||
'    ''rG03ljjBsoMO9p35ib5JQDNDgvKDFoGsvQy5tOaEhd4g2gPshDCywq5HjtfmuHYF'' ||'||chr(10)||
'    ''VTJVtDYuVIZIHpo+15rxIV1TGKTTvEVfupkTy88UKeGzLY4MzxeQjSdPTVmOyO+R'' ||'||chr(10)||
'    ''KC5pVZktCdHzDitM9xk0x+tW+Yu8+mxi0vvuGeYnaEtKmbvG93KTV4+1C5eTvr9Y'' ||'||chr(10)||
'    ''YFLNVEJfzStoJFHPYHPPpTLS02rNjoG2u+bt+l'||
'rsdTDJqvC1+TJM/NyMW5uxy3I1'' ||'||chr(10)||
'    ''xuyyJJwbVk913W0F1D+S/Sa+Gdmoo77a3iWbDUVUj0oD6+nzY9T8KKn9bORFLYV4'' ||'||chr(10)||
'    ''de50bZtxWozLXvI82L53Wcu3uE3F4VdIeS4ftkmg3mJOyf4GRZe8CdMyRaLVM5Fb'' ||'||chr(10)||
'    ''GTopAUwhHy0H4S5UlRHBCsLr4OYjXSh5+U5VVfVdL3lYQu6Aky1pYKqXP9igJ7P3'' ||'||chr(10)||
'    ''OFOlU+kG1JGjpk6sMiLRs02qZQxTrkrZOeoMSJWSPLAIOL2+EJMnC8V6IHeIVZJ0'' ||'||chr(10)||
'    ''uWmW9GnFmUK9vLjYd8SEuk87B/dAgzvYAG5rnbkeWCzcp7sXhCARQdA9APJnotrP'' ||'||
''||chr(10)||
'    ''EWmqJQ6guBYsJTw+djDY3Fur4WvrIuyWbP0qpFx7xSBGBVArehhOVa9Gkv4fjpW+'' ||'||chr(10)||
'    ''u2qW66n0ibabpPT52zDIdD+rTOPiTKrV7e2dmoUZr9UJU/U4DkGpV6l1ukq9S5ZR'' ||'||chr(10)||
'    ''0Sugq+iVfbxKw+Y4UaXeuk5WiUedGfAnE+rk6SlTc/s4t9KQZwjYo29radJoKj7s'' ||'||chr(10)||
'    ''cJAfHBtU5LAPrQnaDmYVdyENIi/fnpLv2fXV3eXV56GNqdZKqtoI9b7fxAg09nPW'' ||'||chr(10)||
'    ''/3RcxHObZtekxRk8fSr8hIudTELHtkDcci501Nwoh0y361qWuFZrGk0ronCve+yV'' ||'||chr(10)||
'    ''g9RclTCUD9G2Esljm0QhvBWm'||
'gnbRQE0H0t3cfMwDtRtpXl/hGdQ9MuXI65VP6bkW'' ||'||chr(10)||
'    ''L8R/rrVq0RStvZJpKDFI19S1+zBXq1FWgNmrhcBSILBO60QYR2qmYDRlzIfdQaOe'' ||'||chr(10)||
'    ''u1K8txSFEUrC0Mtyvx7/nTYvye3UXvvX43HfxeP+yjx2OhcWzzfncX91508Q/4Ss'' ||'||chr(10)||
'    ''w5TFTp5Tyn4BZ9k96h8dHHaPDtbxmVK4VmgsEC7HXlO4LOGB/vkVNnlEXSLIfX3A'' ||'||chr(10)||
'    ''HmfxobayeC5l8WxlKeSzlRgxOt+CGa2YHNHn5TIk+tjTLJ6oElI+b6Av2lXpg7u8'' ||'||chr(10)||
'    ''qUUN9suuxbVKuOhH2+cI2PUzPNb/m2Z5jAQZrEqReBV5EIO1SipiQN'||
'xxxUKpB0WZ'' ||'||chr(10)||
'    ''FHkKMjyH/hQ4R2VBlQTYVlehY5Y/ohQXuL+Cmbgtfg1rf1ljX9HWyRqzSlbPZ9Lf'' ||'||chr(10)||
'    ''zdkJ63WZcx0VEea8oilv04zz30/adkom4jKPgq3AdUIhoGijkH8ZlD/A7eZO0Q5e'' ||'||chr(10)||
'    ''0UyL+tNv49ghG8cZG/tgA5+DcfC11rqIpfTs8A3NAK0ltUWfscwGVVu36DdQteTm'' ||'||chr(10)||
'    ''6fXnq/PW7S/DYWH1bxvlBnbCmFSjdcD2KZLN1sSHXGVqOZ0qkxwUWCP/0m6v/MAL'' ||'||chr(10)||
'    ''V2Lt00PzDEveUWxn6jatVYv5gWMdv+UFgSNuVmU3RyWJjcPHlq6IquR8VOh11/GE'' ||'||chr(10)||
'    ''Ti/47B6wYF'||
'PW4fnqam+VV7NhC8jc0a2px1799T5HmDblb6bD5q1bcZnekJVKyOde'' ||'||chr(10)||
'    ''1zefTv4BzrK3TWfZL3SW5KvsV+Mle6tU7Kqd5/6rdJ4HL+g8D/7PnGcdbV7Ra4p7'' ||'||chr(10)||
'    ''EpobuMwypba4DPTDkpxceEJhAH6geTIhvLErhoh+LJfrPJ+v0PnpqbBzayu+ediR'' ||'||chr(10)||
'    ''6ex/Lp7TL4urJ5ryt01P4a/mlDbgUb+rFT7Oh7+e/Dx8Tk6xqk8iL4MQ1R16fKfh'' ||'||chr(10)||
'    ''dbqHDXLlQ2cgiDpZLGYY3cRzP+ftSNknmqXUwiA+jEJwp/TOjpOzm+tPJ1d0k4h/'' ||'||chr(10)||
'    ''WW1+EEoVrCKAiqgjLgKRQMuMNv93daEl72HyR/9z'||
'ylT49RG/aUX7ek44D3H3j6aj'' ||'||chr(10)||
'    ''IQ0vhH+6j8m9d1MoZiguCiF3D+hfKmjJliRWI5XfOLI3wTOsX/CkMUpkbilq7eX2'' ||'||chr(10)||
'    ''CZ/noNnqR83yx6AKzoNtdKrL6xinuihXTNApDIj+nDW1u45otSqt/P74G9Xz6pQd'' ||'||chr(10)||
'    ''c3G+3oGtZzuy9Q1Ln+u688MhvT6Afmf/73Ift42jItygny1D2bE+yuHP2hgrYqob'' ||'||chr(10)||
'    ''I7BJuwqpuNBindbZIDB3elKSV58/nQ5vvktze9IsQJe/tMiWcNmpn20Jvi8F//Hk'' ||'||chr(10)||
'    ''dPjx+eXuLCsUrDA3Lkaudixp3QrdN1Pll1ZmtFoNhWhV8ICDL+ji+uqOJnAxyDmh'' ||'||chr(10)||
' '||
'   ''9x35AbtpIjMPstpr0w20+/xAJjY3t3c3l1c/f9fv7/r9z9Hvi3Op39R764fnvwfu'' ||'||chr(10)||
'    ''jQM334Vd3zzL9hC2FsJPlRJ8+vzxZRLxF6x/yyrF8yBzKFqNc9sFuHa7KyBzlJmr'' ||'||chr(10)||
'    ''XPQ+Xb2/RaRssiu8dZss6F+Vyw5LvGvp0oa62J5jaVN4EsGqY1cv+13fe5Ibv5v8'' ||'||chr(10)||
'    ''Z377jl9Xa6PUAYkrQMVHB/Lm6CZ6Rz+EbJOfEflwk1xs/e7RI8DFlfLq4jVOAq+j'' ||'||chr(10)||
'    ''dfiVapzAjnZ/9rvHbh0IngnBMyD06kDomhC6BoR+HQg9E0LPgLBfB0LfhNCXEAjb'' ||'||chr(10)||
'    ''/wcr1qSpemAAAA=='';'||chr(10)||
'--'||chr(10)||
'  pr'||
'ocedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex_debug_message.log_message( p_msg );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  t_filename := apex_util.get_session_state(''P1_BROWSE'');'||chr(10)||
'  log( ''looking for uploaded file '' || t_filename );'||chr(10)||
'--'||chr(10)||
'  begin'||chr(10)||
'    select aaf.id'||chr(10)||
'         , aaf.blob_content'||chr(10)||
'         , aaf.filename'||chr(10)||
'    into t_file_id'||chr(10)||
'       , t_document'||chr(10)||
'       , t_filename'||chr(10)||
'    '||
'from apex_application_files aaf'||chr(10)||
'    where aaf.name = t_filename;'||chr(10)||
'--'||chr(10)||
'    delete from apex_application_files aaf'||chr(10)||
'    where aaf.id = t_file_id;'||chr(10)||
'--'||chr(10)||
'    log( ''retrieved!''  );'||chr(10)||
'  exception'||chr(10)||
'    when no_data_found'||chr(10)||
'    then'||chr(10)||
'      raise e_no_doc;'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'  if t_document is null or dbms_lob.getlength( t_document ) = 0'||chr(10)||
'  then'||chr(10)||
'    log( ''file is empty'' );'||chr(10)||
'    return null;'||chr(10)||
'  else'||chr(10)||
'    log( ''file with length '' ||'||
' dbms_lob.getlength( t_document ) || '' found '' );'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'  if dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLSX'' );'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xlsx ) ) ) );'||chr(10)||
'    execute immediate t_parse using t_document, 1, out t_as, out t_as2, out t_as3, out t_as4, out t'||
'_as5; '||chr(10)||
'    for i in 1 .. t_as.getcount()'||chr(10)||
'    loop'||chr(10)||
'      t_dummy := t_as.getinstance();'||chr(10)||
'      t_dummy := t_as.getcollection( t_lines( i ) );'||chr(10)||
'    end loop;'||chr(10)||
'  elsif dbms_lob.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xls ) ) ) );'||
''||chr(10)||
'    execute immediate t_parse using t_document, 1, out t_as, out t_as2, out t_as3, out t_as4, out t_as5; '||chr(10)||
'    for i in 1 .. t_as.getcount()'||chr(10)||
'    loop'||chr(10)||
'      t_dummy := t_as.getinstance();'||chr(10)||
'      t_dummy := t_as.getcollection( t_lines( i ) );'||chr(10)||
'    end loop;'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or d'||
'bms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xml ) ) ) );'||chr(10)||
'    execute immediate t_parse using t_document, 1, out t_as, out t_as2, out t_as3, out t_as4, out t_as5; '||chr(10)||
'    for i in 1 .. t_as.getcount()'||chr(10)||
'    loop'||chr(10)||
'      t_dum'||
'my := t_as.getinstance();'||chr(10)||
'      t_dummy := t_as.getcollection( t_lines( i ) );'||chr(10)||
'    end loop;'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_csv ) ) ) );'||chr(10)||
'    execute immediate t_parse using t_document, '';'', ''"'', '''', out t_as; '||chr(10)||
'    for i in 1 .. t_as.getcount()'||chr(10)||
'    loop'||chr(10)||
'      t_dummy := t_as'||
'.getinstance();'||chr(10)||
'      t_dummy := t_as.getcollection( t_lines( i ) );'||chr(10)||
'    end loop;'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'  t_collection_name := ''anton1'';'||chr(10)||
'  apex_collection.create_or_truncate_collection( t_collection_name );'||chr(10)||
'  if t_lines.count() > 0'||chr(10)||
'  then'||chr(10)||
'    for i in 1 .. t_lines.last()'||chr(10)||
'    loop'||chr(10)||
'      if t_lines.exists( i )'||chr(10)||
'      then'||chr(10)||
'        for x in reverse 1 .. 51'||chr(10)||
'        loop'||chr(10)||
'          t_lines( i )( x ) := t_lines( i'||
' )( x - 1 );'||chr(10)||
'        end loop;'||chr(10)||
'        apex_collection.add_member ( t_collection_name'||chr(10)||
'                                   , p_c001 => case when t_lines( i ).exists(  1 ) then substr( t_lines( i )(  1 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c002 => case when t_lines( i ).exists(  2 ) then substr( t_lines( i )(  2 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c003 => case wh'||
'en t_lines( i ).exists(  3 ) then substr( t_lines( i )(  3 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c004 => case when t_lines( i ).exists(  4 ) then substr( t_lines( i )(  4 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c005 => case when t_lines( i ).exists(  5 ) then substr( t_lines( i )(  5 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c006 => case when t_lines'||
'( i ).exists(  6 ) then substr( t_lines( i )(  6 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c007 => case when t_lines( i ).exists(  7 ) then substr( t_lines( i )(  7 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c008 => case when t_lines( i ).exists(  8 ) then substr( t_lines( i )(  8 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c009 => case when t_lines( i ).exis'||
'ts(  9 ) then substr( t_lines( i )(  9 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c010 => case when t_lines( i ).exists( 10 ) then substr( t_lines( i )( 10 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c011 => case when t_lines( i ).exists( 11 ) then substr( t_lines( i )( 11 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c012 => case when t_lines( i ).exists( 12 ) t'||
'hen substr( t_lines( i )( 12 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c013 => case when t_lines( i ).exists( 13 ) then substr( t_lines( i )( 13 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c014 => case when t_lines( i ).exists( 14 ) then substr( t_lines( i )( 14 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c015 => case when t_lines( i ).exists( 15 ) then substr'||
'( t_lines( i )( 15 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c016 => case when t_lines( i ).exists( 16 ) then substr( t_lines( i )( 16 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c017 => case when t_lines( i ).exists( 17 ) then substr( t_lines( i )( 17 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c018 => case when t_lines( i ).exists( 18 ) then substr( t_lines('||
' i )( 18 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c019 => case when t_lines( i ).exists( 19 ) then substr( t_lines( i )( 19 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c020 => case when t_lines( i ).exists( 20 ) then substr( t_lines( i )( 20 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c021 => case when t_lines( i ).exists( 21 ) then substr( t_lines( i )( 21 )'||
', 1, 4000 ) end'||chr(10)||
'                                   , p_c022 => case when t_lines( i ).exists( 22 ) then substr( t_lines( i )( 22 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c023 => case when t_lines( i ).exists( 23 ) then substr( t_lines( i )( 23 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c024 => case when t_lines( i ).exists( 24 ) then substr( t_lines( i )( 24 ), 1, 4000 '||
') end'||chr(10)||
'                                   , p_c025 => case when t_lines( i ).exists( 25 ) then substr( t_lines( i )( 25 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c026 => case when t_lines( i ).exists( 26 ) then substr( t_lines( i )( 26 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c027 => case when t_lines( i ).exists( 27 ) then substr( t_lines( i )( 27 ), 1, 4000 ) end'||chr(10)||
'    '||
'                               , p_c028 => case when t_lines( i ).exists( 28 ) then substr( t_lines( i )( 28 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c029 => case when t_lines( i ).exists( 29 ) then substr( t_lines( i )( 29 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c030 => case when t_lines( i ).exists( 30 ) then substr( t_lines( i )( 30 ), 1, 4000 ) end'||chr(10)||
'              '||
'                     , p_c031 => case when t_lines( i ).exists( 31 ) then substr( t_lines( i )( 31 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c032 => case when t_lines( i ).exists( 32 ) then substr( t_lines( i )( 32 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c033 => case when t_lines( i ).exists( 33 ) then substr( t_lines( i )( 33 ), 1, 4000 ) end'||chr(10)||
'                        '||
'           , p_c034 => case when t_lines( i ).exists( 34 ) then substr( t_lines( i )( 34 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c035 => case when t_lines( i ).exists( 35 ) then substr( t_lines( i )( 35 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c036 => case when t_lines( i ).exists( 36 ) then substr( t_lines( i )( 36 ), 1, 4000 ) end'||chr(10)||
'                                  '||
' , p_c037 => case when t_lines( i ).exists( 37 ) then substr( t_lines( i )( 37 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c038 => case when t_lines( i ).exists( 38 ) then substr( t_lines( i )( 38 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c039 => case when t_lines( i ).exists( 39 ) then substr( t_lines( i )( 39 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c040 '||
'=> case when t_lines( i ).exists( 40 ) then substr( t_lines( i )( 40 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c041 => case when t_lines( i ).exists( 41 ) then substr( t_lines( i )( 41 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c042 => case when t_lines( i ).exists( 42 ) then substr( t_lines( i )( 42 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c043 => case wh'||
'en t_lines( i ).exists( 43 ) then substr( t_lines( i )( 43 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c044 => case when t_lines( i ).exists( 44 ) then substr( t_lines( i )( 44 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c045 => case when t_lines( i ).exists( 45 ) then substr( t_lines( i )( 45 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c046 => case when t_lines'||
'( i ).exists( 46 ) then substr( t_lines( i )( 46 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c047 => case when t_lines( i ).exists( 47 ) then substr( t_lines( i )( 47 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c048 => case when t_lines( i ).exists( 48 ) then substr( t_lines( i )( 48 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c049 => case when t_lines( i ).exis'||
'ts( 49 ) then substr( t_lines( i )( 49 ), 1, 4000 ) end'||chr(10)||
'                                   , p_c050 => case when t_lines( i ).exists( 50 ) then substr( t_lines( i )( 50 ), 1, 4000 ) end'||chr(10)||
'                                   );'||chr(10)||
'      else'||chr(10)||
'        apex_collection.add_member ( t_collection_name );'||chr(10)||
'      end if;'||chr(10)||
'    end loop;'||chr(10)||
'  end if;'||chr(10)||
'  apex_util.set_session_state( ''P1_COL_NAME'', t_collection_name );'||chr(10)||
'  '||
'return null;'||chr(10)||
'exception'||chr(10)||
'  when e_no_doc'||chr(10)||
'  then'||chr(10)||
'    t_rv.success_message := ''No uploaded document found'';'||chr(10)||
'    return t_rv;'||chr(10)||
'  when others'||chr(10)||
'  then'||chr(10)||
'    log( dbms_utility.format_error_stack );'||chr(10)||
'    log( dbms_utility.format_error_backtrace );'||chr(10)||
'    t_rv.success_message := ''Oops, something went wrong in '' || p_plugin.name ||'||chr(10)||
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms_ut'||
'ility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'    re'||
'turn t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.800'
  );
null;
 
end;
/

commit;
begin 
execute immediate 'begin dbms_session.set_nls( param => ''NLS_NUMERIC_CHARACTERS'', value => '''''''' || replace(wwv_flow_api.g_nls_numeric_chars,'''''''','''''''''''') || ''''''''); end;';
end;
/
set verify on
set feedback on
prompt  ...done
