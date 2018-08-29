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
'  e_no_doc exception;'||chr(10)||
'  t_rv apex_plugin.t_process_exec_result;'||chr(10)||
'  t_time date := sysdate;'||chr(10)||
'  t_what varchar2(100);'||chr(10)||
'  t_file_id number;'||chr(10)||
'  t_document blob;'||chr(10)||
'  t_filename varchar2(32767);'||chr(10)||
'  t_parse varchar2(32767);'||chr(10)||
'  p_browse_item varchar2(32767);'||chr(10)||
'  p_collection_nam'||
'e varchar2(32767);'||chr(10)||
'  p_sheet_nrs varchar2(32767);'||chr(10)||
'  p_separator varchar2(32767);'||chr(10)||
'  p_enclosed_by varchar2(32767);'||chr(10)||
'  p_encoding varchar2(32767);'||chr(10)||
'--'||chr(10)||
'  t_parse_csv varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC8VZbYvbOBD+3l8h+iU2l11WL/vWvRbKUu4KRwttOe6bcWwla86x'' ||'||chr(10)||
'    ''g+1st0d//I3kt5Eym+hK4QLbxPYzo9GjZ8Yj9UWuszJt9AvGum87zbpdsi50mbes'' ||'||chr(10)||
'    ''aFmXrkrN6jV7TJvsIW1EJMX11XXMiirXT2z1je3KNimqTm90c4dclEWlXQ/I7wnb'' |'||
'|'||chr(10)||
'    ''PO1S33Tw95xlbzPY9neyuix11hV1lazSVvszOABV6ZYGDVEJwDpRpTv9lKS7XVlk'' ||'||chr(10)||
'    ''qfWwKetVWp4/ZknaNOJIsNbV4PLuxdkZ3Nw1dabzfaNZWW8itku27WaKhsWAKFr4'' ||'||chr(10)||
'    ''Z6U3RQUWDD52/Fyv9ptkq9s23ehz3TR1M1rb6EkYDDH+HsBL+Cr1oy7Z6zdMGdOz'' ||'||chr(10)||
'    ''s3y1bZN63+323Tn82SVwfOsqH6Jf7ytLIoPQCzzfJWvcywxf2nk1uts31TRXd6Zm'' ||'||chr(10)||
'    ''AgMgM4v49UFXw2pHRRw18bl+KtqujbKYdeZZu1+1HVCAMfBwyfiSqYuLCxb3YePo'' ||'||chr(10)||
'    ''Z+53adPqJGsf7cBmsnmd7be'||
'66tgKFtfeNVS1ejcvzqvXbHG3mJ7pKivrVucu4KUD'' ||'||chr(10)||
'    ''qPOi2jiAal+WFjEttZVn+8jA2+puuM512yX1et3qDlADiWDNR0DbZNNzEmCmAW6L'' ||'||chr(10)||
'    ''3FxW++2qf57VaanbDNa3guUxUYGLpMgjHG9sfZz8LA987LsyKfhNdb5Nd+MD7Hk5'' ||'||chr(10)||
'    ''I3579+Hdp/f3yf3HD1/e/fUFPXn/9sPb5MvH5OOnt/d/vIN1/OFwFve/v/2U3H9e'' ||'||chr(10)||
'    ''hLqIR/bKtNpAzQBenzrEns0UIPY81+t0X4647mm0+5o2lWHQflApMM801IKp7Ahm'' ||'||chr(10)||
'    ''vqfxsM4i3j+zankso0nqVo5W4JyB0EGLc8AHYjziZcQiVy+RqxKyy'||
'6tk5vaubqnb'' ||'||chr(10)||
'    ''bZc23TN4O2XikSkwSVaRZvbVATfz5wzb6S3R37VpnKyhfjH9lOmdKU93Tl2xhXZh'' ||'||chr(10)||
'    ''Ut4szf3nP9nXonuw9KRZp41c2IJ9/+7ox7wlIieP4pGiSQVZo9NOd3q7q5u0+Rb1'' ||'||chr(10)||
'    ''ibxkXbPXh+C6etRN19UmzwfoEVUuUU06CpsGgL9t+tQW/+ijeKe4nEDOVeYEcGLp'' ||'||chr(10)||
'    ''BA7n1QnokEpHUPFQ1iHT1pBsw+vArkD20ERcxmZR7c8LWDz2hl30OoL3x+C2z0pT'' ||'||chr(10)||
'    ''Fw8MBnWVrSaxEwCUWqynSPr0ARB8bbqHIaA5ufp0wYV6SgZ8c86C+W5Z17shFHgX'' ||'||chr(10)||
'    ''duMrsvf4p'||
'h/5bgAAIfMLstdkD7QJz16jijHObiZlyrQIhxdHTly2sCwWd8hmmtv4'' ||'||chr(10)||
'    ''85cxdC/8Hm4KCoDdhetQdRrdxHfIDmbWm74eVpMI33yatIA2Yi4O2Me4Zo7XA77M'' ||'||chr(10)||
'    ''IL8MJZJijBw2lLkgHIjxuVXswzvDVLs8eQvST0Y4LMzS/n9j9+IOWgt4E7qx+wtx'' ||'||chr(10)||
'    ''ev49xsk0fOmId+DraGhzxps6EY+iqcsfCJTDn+fvMHRcOdDVQeDPFRR3Yv3Qv/Z1'' ||'||chr(10)||
'    ''5FTIx7KrVxaDvYs2OyPoSCr2AK/YFbx2UggAeild/O2Xf4oEz+tB1vaF8Fhmm2tT'' ||'||chr(10)||
'    ''eMY7juafLUG2zSLUOTc1VN2qS9IIFyxm5j97wSX'||
'Mbmr+A2ehyUonoSsnl8VeDtEQ'' ||'||chr(10)||
'    ''9RsctZXHGH3M6ubIZH5arCcKxinhhKa4Vw5/SsyWmMC4LfZo1odm/PPZ7qYHvnIT'' ||'||chr(10)||
'    ''Zeop140+6G/nZsbuvIdv6G/3VRfFzivCbr/Hptwa2aalBn00rd+LBQxqt/JjY394'' ||'||chr(10)||
'    ''8gMDv4J7tnc38GmXH7FXtptemm+b3a/6bdD4o3ffbxTMBsFaQgtitwV4guZ6wdoH'' ||'||chr(10)||
'    ''iLBlUPmqfDH1ob35tn4024yuZvdTeFEbDxusNeRMAbUDsur83PV8xvgL1CYdnllZ'' ||'||chr(10)||
'    ''Xv05m/hqu2uJ7NlCsY5YsWTm/AP1BE5oNvp+auYUx8KcQ6R5jGGLk9RNApuaKjO/'' ||'||chr(10)||
''||
'    ''56cREaTTlE+HM5M6yB7cHI/BlrqEVR+1aXhqDE985sn4KdN2rIJOQ+kMNhwVNfOu'' ||'||chr(10)||
'    ''/6AgmSEjxs2pkeF1ExXLBroLL996lPBQgkRJDyVJlPJQikRdeqhLEnXloa5I1LWH'' ||'||chr(10)||
'    ''uiZRNx7qhkTdeqhbCgVbIwc1bZVclMc9J7nnHvec5J573HOSe+5xz0nuucc9J7nn'' ||'||chr(10)||
'    ''Hvec5J573HOSe+5xz0nuucc9J7kXHveC5F543AuSe+FxL0juhce9ILkXHveC5F54'' ||'||chr(10)||
'    ''3AuSe+FxL0juhce9ILkXHveC5F543AuSe+lxL0nupce9JLmXHveS5F563EuSe+lx'' ||'||chr(10)||
'    ''L0nupce9JLmXHveS5F563EuSe'||
'+lxL0nupce9JLlXHveK5F553CuSe+Vxr0julce9'' ||'||chr(10)||
'    ''IrlXHveK5F553CuSe+Vxr0julce9IrlXHveK5F553CuS+0uP+0vM/UFX3Rez0QIf'' ||'||chr(10)||
'    ''IB02p3jn5jcmaZ4nW20O5luiDfE2l8THnK9mFxfc/D/Y3A4E2wlsJ8LtJLaT4XYK'' ||'||chr(10)||
'    ''26lwu0tsdxlud4XtrsLtrrHddbjdDba7Cbe7xXa3wXb8AtlBgxJsh/XCw/XCsV54'' ||'||chr(10)||
'    ''uF441gsP1wvHeuHheuFYLzxcLxzrhYfrhWO98HC9cKwXHq4XjvXCw/UisF5EuF4E'' ||'||chr(10)||
'    ''1osI14vAehHhehFYLyJcLwLrRYTrRWC9iHC9CKwXEa4XgfUiwvUisF5'||
'EuF4E1osI'' ||'||chr(10)||
'    ''14vEepHhepFYLzJcLxLrRYbrRWK9yHC9SKwXGa4XifUiw/UisV5kuF4k1osM14vE'' ||'||chr(10)||
'    ''epHhepFYLzJcLwrrRYXrRWG9qHC9KKwXFa4XhfWiwvWisF5UuF4U1osK14vCelHh'' ||'||chr(10)||
'    ''elFYLypcLwrrRYXrRWG9qHC9XGK9XIboxfvvarfBno4HdU4fXJqD138BT8FPdkAo'' ||'||chr(10)||
'    ''AAA='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xml varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC6WY227jNhCG7/MURG4so7bXPOTkYLcttihQYNuLIkV7Z8gS7ajR'' ||'||chr(10)||
'    ''wRDlJAvsw3dInUYTJsvdGkgsUzPk8OPP4Uhnq'||
'U7yuNZnjDXbtEpOhS4btsur3a1t'' ||'||chr(10)||
'    ''+nzUrDlu95nOU8Myw5p4l2tW7dljXCf3cS0iKa4ur+YsK1P9zHaf2TE326xs9EHX'' ||'||chr(10)||
'    ''uIs8K/W0B9TvV3zTuImpa9ffa56tT+fbtiRVnuukyapyu4uNpjN4YVTGhd+oi0qA'' ||'||chr(10)||
'    ''7SSq+Kift/HxmGdJ7Ho4AMY4Xz0m27iuxRvBuq66Lm/PlktoPNZVotNTrVleHSJ2'' ||'||chr(10)||
'    ''3BbmMETD5mCRGfi304esBA8GHzd+qnenw7bQxsQHvdJ1XdW9t4veawZD9Ned8QK+'' ||'||chr(10)||
'    ''cv2oc/b+A1PWdblMd4XZVqfmeGpW8OeWYNK3LtMu+v2pdBAZhJ7h+S5YPf2Z4J9u'' |'||
'|'||chr(10)||
'    ''XrVuTnU5zHU6UzuBziCxi/h0r8tutaNsHtXzlX7OTGOiZM4ae8+cdqYBBNgGbi4Y'' ||'||chr(10)||
'    ''XzC1Xq/ZvA0bRz+yP8a10dvnIncD28lO9ohrtajMvdaNGddn856Vp7z1GtbKrrT1'' ||'||chr(10)||
'    ''2iYmS+F+sYMZW0sAYN2MbrZZGrHZz5+k+Ovu1+sZYGWwtsm9Th4gvqRKs/IAOmL/'' ||'||chr(10)||
'    ''/P6J/QifrlcIkMGfVeZt19Tuj36j9K0uzrKmCrS36urJ12yV6Wl+jHPf3uh2nt7u'' ||'||chr(10)||
'    ''i2a8z9fruZ3oLE2XRbH8DB92fy/Upsg2xsx6x3IEGIneBaZVmvfnsOAbAxyK2CyL'' ||'||chr(10)||
'    ''LKkrU+2bZVIVm2q/zxK9Mcd'||
'ax6mb3zmbsS9fXKf+T9spDP2N/Y6RpsxtBugnrYoV'' ||'||chr(10)||
'    ''/JVVOqAvc9/dHGQ5Woivm8i3TMbd4NLDzArVasMK4ylr7pnFGCeNtqpyPCYys7kt'' ||'||chr(10)||
'    ''mshxzoYFtGoC9J2gsOgXUxeqKnBaI0TwE8+giB+0nUI0aT3opu9d59p+Te+X+gm+'' ||'||chr(10)||
'    ''epOoC2+O4y3zcSiTu81rTFWvjLap3A5pIhfRgs3e/V3VD7uqenAXLvDZotVe19++'' ||'||chr(10)||
'    ''qiFlwR5bs9WKhprr8tDcR+2gc7ZkvFuD6tjpbUJj/PED47edRbaHRDLmDDhBhlTh'' ||'||chr(10)||
'    ''Pnb80uWs2cYt3GAK19C06Nubyq1nhIaZdzZw8YGtv6PPlxRhp590t'||
'Z+uStbooqWw'' ||'||chr(10)||
'    ''AFiQTWc/GbP5A1Q10HwlknnPCZLz0NqlqxXoWzf6FrXbrAQgOW6zu+frC/52uHf2'' ||'||chr(10)||
'    ''0H73Z/VEVr9XwL8hChBIAkQGk+jLxzz6drJiAVH0aH+ztcMQ6yu5bdEO+cpdNMM+'' ||'||chr(10)||
'    ''sU/J9mnne9kOAX/Uee7h2pJ9CCErCdkXbNEMvo+uXEAk30S35QuDvnp/Mtf+lPTS'' ||'||chr(10)||
'    ''DA0OYvsFyhYvTJdJ/nfX7+z87yDPjxsXTl24o+8y2M3TCeE9S+Y4JqPKVQBRewsG'' ||'||chr(10)||
'    ''sse9PfbT9PzufDz2V+dQfZ3PbCyoZiAzhJoMZkmxumQROa3PI7ck8zbbwoDUthNJ'' ||'||chr(10)||
'    ''e/HDVO62d'||
'6urW9+mbS8mHi/tu6qy+14l1QnOKHs4uQ5Q6TVMZULvjPba16D98f7y'' ||'||chr(10)||
'    ''qQU63kCbO8Gtx1ChRmzjDuqF/e6Su6PZFgi2MHC29hR0pwcK2eVq1jntoSWdtSX/'' ||'||chr(10)||
'    ''4F5Uj7a8aCr2cQgoMvNZO8T0zJz03O7iYfe+fMLqF2cyS3y62dMxAz1nC2ardViR'' ||'||chr(10)||
'    ''XiWT0Fz07dTsM4czmzzyjGOsEqjpQHBVvW1qeFKx1+PdyBNkD8PtueFRYljv/oRD'' ||'||chr(10)||
'    ''G6R9qCMnmuVkT2KIbeBk+8lj03Qmkzw3Gax7sKnH/ET2YztkxLh9xrFcD1G2gEcs'' ||'||chr(10)||
'    ''TjJ/ayWIlfBaSWIlvVaKWCmv1QWxuvBaXRKrS6/'||
'VFbG68lpdE6trr9UNsbrxWfH1'' ||'||chr(10)||
'    ''1Ap++6wIe+5lzwl77mXPCXvuZc8Je+5lzwl77mXPCXvuZc8Je+5lzwl77mXPCXvu'' ||'||chr(10)||
'    ''ZS8Ie+FlLwh74WUvCHvhZS8Ie+FlLwh74WUvCHvhZS8Ie+FlLwh74WUvCHvhZS8I'' ||'||chr(10)||
'    ''e+FlLwl76WUvCXvpZS8Je+llLwl76WUvCXvpZS8Je+llLwl76WUvCXvpZS8Je+ll'' ||'||chr(10)||
'    ''Lwl76WWvCHvlZa8Ie+Vlrwh75WWvCHvlZa8Ie+Vlrwh75WWvCHvlZa8Ie+Vlrwh7'' ||'||chr(10)||
'    ''5WWvCHvlZX9B2F9g9jo32pPMeo/ZbFozjhUsrSBpYRKn6bbQ9sWg8ZQhb7zS6j72'' ||'||chr(10)||
''||
'    ''XWSyXnP71nYsB4L9BPYT4X4S+8lwP4X9VLjfBfa7CPe7xH6X4X5X2O8q3O8a+12H'' ||'||chr(10)||
'    ''+91gv5tgP75GflCgBPthvfBwvXCsFx6uF471wsP1wrFeeLheONYLD9cLx3rh4Xrh'' ||'||chr(10)||
'    ''WC88XC8c64WH64VjvfBwvQisFxGuF4H1IsL1IrBeRLheBNaLCNeLwHoR4XoRWC8i'' ||'||chr(10)||
'    ''XC8C60WE60VgvYhwvQisFxGuF4H1IsL1IrFeZLheJNaLDNeLxHqR4XqRWC8yXC8S'' ||'||chr(10)||
'    ''60WG60VivchwvUisFxmuF4n1IsP1IrFeZLheJNaLDNeLwnpR4XpRWC8qXC8K60WF'' ||'||chr(10)||
'    ''60VhvahwvSisFxWuF4X1osL1o'||
'rBeVLheFNaLCteLwnpR4XpRWC8qXC8XWC8XIXrp'' ||'||chr(10)||
'    ''avKxyMYF9vB6UKf+F5f2bet/wC970gEjAAA='';'||chr(10)||
'--'||chr(10)||
'  t_parse_xlsx varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC+VbbY/bNhL+3l9B5IvtW69tvuz7bZF2k6ABmqJIUqCHu4OhtWiv'' ||'||chr(10)||
'    ''GlkyJHmzW/TH35CipCFFrblJ+umUJralmeHw4TPDIcV+F8tVGhXyO0Kqx50k1W65'' ||'||chr(10)||
'    ''TmQalyQpSRXdppLka3IfFau7qGBjzs5OzyYkyWL5QG4fyS4tl0lWyY0srpCJNMmk'' ||'||chr(10)||
'    ''bQHZPaAbR1Xkqhp7Q5q1jtGt76zyNJWrKsmz5W1USrcHPaEs'||
'2vqFjFcMZC2vop18'' ||'||chr(10)||
'    ''WEa7XZqsIm1hk+a3UTq7Xy2jomBPOKtNGZNX3x0fw81dka9kvC8kSfPNmOyW23LT'' ||'||chr(10)||
'    ''ekMmIJGU8M+t3CQZaBC4dPuxvN1vlltZltFGzmRR5EWjrb33ikETzXcjPIWPVN7L'' ||'||chr(10)||
'    ''lFx/T4RSPT6Ob7flMt9Xu301g796CCzbMouN9+t9pkEk4HqC+zslhf1zhX/qfhWy'' ||'||chr(10)||
'    ''2hdZ21e7p6oDRmClBvHznczMaI+TybiYzORDUlbleDUhlXpW7m/LCiDAMvBwSuiU'' ||'||chr(10)||
'    ''iMViQSa1217vb2EAWZbHupvqh76DvdSYPGzTON/O4K+S7TucrBt1oEu2T1OSF7Um'' ||'||chr(10)||
'    ''3Jtt'||
'ZJXKbFPdtY1MyDVZaE3VBf2lbVCp1+MI/oLlKwwJ9mYbfZK16/guNBbnq/1W'' ||'||chr(10)||
'    ''AuCpVB/280x+ho9GZEzgtuJ749qUZDBaalxKWS2TeExGP/zM2W8f35yPwG3z50k0'' ||'||chr(10)||
'    ''91sLzJpoGWkJsVvu8pJ4CAGat7IYpMO+SpdF9HkGtKiWVb68TbKoeGyYNe7wbhjR'' ||'||chr(10)||
'    ''9Ei337QLxGgMpUkFA7OEjiRRNtgpS0obTTbGVWXz9rGCNIUpfnmt4qnrFjR1sE+N'' ||'||chr(10)||
'    ''y1Yf10W+7fVStz/YB836xqmhHkEOWkbpuu6NSkxW1jGeoR4Neh+VqyQZkw5vMDYl'' ||'||chr(10)||
'    ''x1ST5JicCsNsuI5Idp+OyXhIh4HnrRp8/I'||
'Ow0ylZaI8CTfCeidOz2sZQ6gKGr5NU'' ||'||chr(10)||
'    ''6iaUnT+T3U7GHXX1A4WnkrKnC/0IwWXENU4q4Vfbnb53ZX4nKpa7GUHduot9d9ep'' ||'||chr(10)||
'    ''767MVnmcZN0EMaaLSfMQRdeVNUx1s8BHfyrC3VWoMVpbTPN8Z2CHXFs1KVjZ+idA'' ||'||chr(10)||
'    ''jFNbNwbIGOTdqZFXie5OPlQ5cBVSyclC/Lg4WZxCKrkiMKe9BhGYV1eQiYooJXFS'' ||'||chr(10)||
'    ''wNScF4+kTDZZBMBK40fbk/rLMaFdilTumqHVmdh4+pwMa5TbMYGGcC7z9+2I0FPo'' ||'||chr(10)||
'    ''4FHjyxqASWAgAKLZbFifdfrnht4IcPC/Ce3bpFpGWexNbJZFOu08PyIXKgsgzBcm'||
''' ||'||chr(10)||
'    ''cV/3bjbYdgBZVAMQutyvh2tfrc8bYqSlHFL67cP5rzeCn9VKb398BxknljuoPQjc'' ||'||chr(10)||
'    ''bQygyc1MoF2UXWsQEnqezcBflewV6btU4F6HMBrW7F3TAyPX4szOcXIKsIt0xekz'' ||'||chr(10)||
'    ''NJ9oZYqgH5YaGGiVNg4SveuuMDEL2TPf7gooJiXEnk4mrVEdfcpuE3y9ZrVMN0bt'' ||'||chr(10)||
'    ''kJtpA6IH2DkfTcnoPyOr57rWU+23SWK+ztNY2qzoRXh9KbYqXbndVY+kzfmOln6q'' ||'||chr(10)||
'    ''Oz+eWNoWVXtZw3TqUJTa7KGLfkguFipSVRflOo0qOYRgO0mEj55gxOpSPUFdWg7Q'' ||'||chr(10)||
'    ''N+c/KifQxZtEvQHbIBvZ'||
'eLddXuW7x3FtdIiG07CInJJgQi6GIwNyIh1+1uJ3RPig'' ||'||chr(10)||
'    ''2NGBPNCaYGf1oL0BVhGdvZyg+GLDF7Xh1w8wORK9kj5g2hridnBgwSrVNKKHp6sc'' ||'||chr(10)||
'    ''V3kGq9jDs4uNup7ywKmb9zecPSOJNdg71XSdLSaH8kro9USqtLBB1XfT6Cz9c9m5'' ||'||chr(10)||
'    ''YNDCWn9T1C/aqP94J3VqUmvIEp4DDOMsJ41LULFO/saM0MVyISH3VJAMwcXiseVN'' ||'||chr(10)||
'    ''VezlkMo3DH/NiCfi+v89rA11Ndh9cvp+4ar26RrkUB+s2ocEoRNski+MyQBcwo0y'' ||'||chr(10)||
'    ''M39pPyGS1J4HttpbPzgFRLdq7LbrdmpvZPmQlg/twrHZTrFXje'||
'WdlFXZra4Bf2W3'' ||'||chr(10)||
'    ''XTq2i8UYAo5eLAS5zfNURplZ2HWbo9LahjRSg9uNyuTDutYz+s1tgGy9rXyPTGOQ'' ||'||chr(10)||
'    ''w6CW/LKdYNWA7vMyiUtkzH6m2OJ9alruPyl8m7RaZehBNfTgPkqHHmWF2dVpl9V6'' ||'||chr(10)||
'    ''A7rZib5CY7UEDPFKfDHR6544Pt5ujx/hInd3TFxuk8uyHLX2kbesUXnYpll5/eKu'' ||'||chr(10)||
'    ''qnaX83m5upPbqJzlMGHDE1hQbqMKfhabeQlzQBRrBLfpHPRP59soyV505mPfVmX3'' ||'||chr(10)||
'    ''lD35OPU9TZOy6iS8BmwRPiyiYwjvTODJSm9iNrsxOJ5gGfCQzj/nxSfg/KcZGB41'' ||'||chr(10)||
'    ''249W3I'||
'ClNP/cbgI+lKkO17LMixkM+V7m67FuEwy25tovvxbzl42p0bQeqkm7GFHz'' ||'||chr(10)||
'    ''nlqP0FHXMODV7KpYbZVSvVtQ/Sk97dX5oP5o23H2DhZq78DZz212bHS7aqOGursG'' ||'||chr(10)||
'    ''KO7UdvyR3gjzetiigdtIYLavzU9BewJOvywuk1j1WhP0sgihaL5eJyv5ygxdzdFC'' ||'||chr(10)||
'    ''pvpNSXmX7MoXo24qs7LBN/JZ2Wqb6DL7s/lWVo+pLHtse9agaxsfVBfnkFXebGHc'' ||'||chr(10)||
'    ''689vPfAqo30VavUQ3oD7aHigsh3Dv5l5swK2piq/KTy+R0t7tRfoCG23AUKPjz2h'' ||'||chr(10)||
'    ''gU0KNGE9GdyHqKGxfxvXW2GqEIKo9pVLPdrg'||
'9qlwlV2Bk0MCp4cEzg4IMOYR+EJm'' ||'||chr(10)||
'    ''rmSa/r4u5w/reYfQN+anKURUiNd+4+407/Jcw8plPbRPDmwXnF8T7DAhy/hDXXE4'' ||'||chr(10)||
'    ''MQ9RkOWV7UKpSrgaTcNZxNjnDkVZzcvEQfzLMLdQR+VUi/sXx84MpQUbZxw3dYkR'' ||'||chr(10)||
'    ''CvoS5oXSmtdn6g6C3t5MR/MbLDb3WeXyTOertuI2L2F9GWh0OSJ//dWJwne4NW3u'' ||'||chr(10)||
'    ''m53mGrX62XA2O2TLneKGLA6kvsOZXYOuiPQeT7PWr3+/fBtfv7D8MUVC7c2L/85f'' ||'||chr(10)||
'    ''foyKja5IwsvRXbT6FG3kgUm+raJnUAbKSuL7zwhR473CY2IbVyXn8woxDUFdgr2K'' '||
'||'||chr(10)||
'    ''qmhe5J8thxXvipDY41bwOeHXVMyHffPHHlenKFTwrUb26l+590eIe8xxr+dgvbD6'' ||'||chr(10)||
'    ''ksQAjPvDFIm91BXO3QO270d9o9VXulv1bOr3FRWBhVg5shu7621CaVnVL5VdYFaw'' ||'||chr(10)||
'    ''M8yQFgID5WRIM/Vac+zjdX25bx30vbQ0LtdrEzCowjbJVJR9qH9Is52ownWfRlOi'' ||'||chr(10)||
'    ''jwgd6p37xsR5w9d0pfzKISh7Q2CALTGsJIK+t6VDWyRYqNVLNEvQJxE2QpmOBHdU'' ||'||chr(10)||
'    ''Dm8/T9EZJafEfT1Cp3wOXvrtVlVEWZnWHTFWZgvKuDg5PTufHh+p0X110Vyj0NeP'' ||'||chr(10)||
'    ''+uUXst0dmNJt0KnX9WO1Hj'||
'vogZ5DXsM1CvEFKB2C6eiXnz8sf/nt3ev3b2+WNz/9'' ||'||chr(10)||
'    ''8P6Hm4+v33+4nk0DWunRyxCsWeD3R99HCRy2TUkAXzTLRgt6DP/VuwWjV6+O3707'' ||'||chr(10)||
'    ''/hdcI3UWwOJQppM42jPyOOcJs4DmuWp+0W9+3HdAHYehAX540s1AEvLcM/P8mKSQ'' ||'||chr(10)||
'    ''4nTUq4OA6PuopdFFc45sjA8iHZDV6RMQcV/LdsWo/445FGg+69px3BpEG3vDq8Bm'' ||'||chr(10)||
'    ''C7jZvOqfMwVbl6orqtBTGt0G8Zhc6mJmqj5Nlaix10c+R7///OH3WlrVJ3WV0/mp'' ||'||chr(10)||
'    ''Y4sYrTXciUf1Mc1Wf5vfqzMXVU5uWpfG5cTkWHsZYVmuK4O2Iuif'||
'itXwuP3E9bFK'' ||'||chr(10)||
'    ''0wkk/EQfsKp3b5rTQ8g17X3dtW6TBx9T7dowL56WebGEta16NynR07HHyYl96scc'' ||'||chr(10)||
'    ''/2wH+fv+AaD6IK5TjbYlH+1wUnbSqKx8ayurMTM3FU+8mlNNwsJenUtVuG7GyRRI'' ||'||chr(10)||
'    ''Tp338bUUc6SYV4o7UtwrJRwp4ZU6caROvFKnjtSpV+rMkTrzSp07UudeqQtH6sIn'' ||'||chr(10)||
'    ''RRe2VHsozpZysKde7KmDPfViTx3sqRd76mBPvdhTB3vqxZ462FMv9tTBnnqxpw72'' ||'||chr(10)||
'    ''1Is9dbCnXuyZgz3zYs8c7JkXe+Zgz7zYMwd75sWeOdgzL/bMwZ55sWcO9syLPXOw'' ||'||chr(10)||
'    ''Z17smYM9'||
'82LPHOyZF3vuYM+92HMHe+7FnjvYcy/23MGee7HnDvbciz13sOde7LmD'' ||'||chr(10)||
'    ''Pfdizx3suRd77mDPvdhzB3vuxV442Asv9sLBXnixFw72wou9cLAXXuyFg73wYi8c'' ||'||chr(10)||
'    ''7IUXe+FgL7zYCwd74cVeONgLL/bCwV54sT9xsD/B2DuVdJPMGo3RyC4U7eMSuGx0'' ||'||chr(10)||
'    ''C5MojpdbqWrq0lOGhKxodsvVYkHV/2nTlQPBegzrsXA9jvV4uJ7AeiJc7wTrnYTr'' ||'||chr(10)||
'    ''nWK903C9M6x3Fq53jvXOw/UusN5FsB5dID0oUIL1MF9oOF8o5gsN5wvFfKHhfKGY'' ||'||chr(10)||
'    ''LzScLxTzhYbzhWK+0HC+UMwXGs4XivlCw/lCMV'||
'9oOF8Y5gsL5wvDfGHhfGGYLyyc'' ||'||chr(10)||
'    ''LwzzhYXzhWG+sHC+MMwXFs4XhvnCwvnCMF9YOF8Y5gsL5wvDfGHhfOGYLzycLxzz'' ||'||chr(10)||
'    ''hYfzhWO+8HC+cMwXHs4XjvnCw/nCMV94OF845gsP5wvHfOHhfOGYLzycLxzzhYfz'' ||'||chr(10)||
'    ''RWC+iHC+CMwXEc4XgfkiwvkiMF9EOF8E5osI54vAfBHhfBGYLyKcLwLzRYTzRWC+'' ||'||chr(10)||
'    ''iHC+CMwXEc6XE8yXkxC+oEMZdZGNC+x2e1DG/o1Ltd/6P/62oxaiQAAA'';'||chr(10)||
'--'||chr(10)||
'  t_parse_xls varchar2(32767) :='||chr(10)||
'    ''H4sIAAAAAAAAC+1d63PbuBH/nr8C/dCRdJFdAqRkOT'||
'lnxrHla6a2c2M70/aThpZo'' ||'||chr(10)||
'    ''m40kakjqEnfujy/eXIAgRT38uF407UXGYxf7w2KBBRbQm0k0noZp9Aah/HERoXwx'' ||'||chr(10)||
'    ''uouj6SRDcYby8HYaoeQO/Ram44cwJW2fHPQPOiieT6Lv6PYRLabZKJ7n0X2Uvgck'' ||'||chr(10)||
'    ''pvE8MikAuivqTsI8tKtKelU1RR1ZV6SMk+k0GudxMh/dhllkS1AqNA9n7kKyVYSW'' ||'||chr(10)||
'    ''NVoVLqLvo3CxmMbjkFO4nya34XT/t/EoTFNS01hOSpJ8/2ZvjyYu0mQcTZZphKbJ'' ||'||chr(10)||
'    ''fRstRrPsXrcGdWiJOKP/uY3u4zmtgeiH859Et8v70SzKsvA+2o/SNElVbd56ZzHK'' ||'||chr(10)||
'   '||
' ''Qn2Xhbv0n2n0WzRFRx9QwKru7U1uZ9koWeaLZb5P/8+7wKAdzSey9XfLOQcR0abH'' ||'||chr(10)||
'    ''UN4uSs0/x/BPLlca5ct0rmU1JWUCyAJj1onfHqK57O123Gmnnf3oe5zlWXvcQTnL'' ||'||chr(10)||
'    ''y5a3WU4hgGVoZhfhLgo8z0Md0WzY+gL7RZhm0ej7NOOMmbCTZLycRfMc3dLO5akM'' ||'||chr(10)||
'    ''quwhivKs6J93R2i+nE55vu4r1tPfkvTrbZJ85dXfy0SqGAjoA0vKHGlTKo6VNAu/'' ||'||chr(10)||
'    ''u5LHtH1W0n16G+coDb+1cUel3cZ3dz1EmzONwrnmnKe8WKHwLDWfLRypaTR2pFKg'' ||'||chr(10)||
'    ''I3zoBRZlOWyyLN/IkPC20bqChEmT'||
'cTSISs61xL7fiXqyvkq+m+WudMmJVqIFDF5Q'' ||'||chr(10)||
'    ''f1fwY1U1EcDQZWZ4P9K0URaBfOx5HaZdrX8OBxfX//x0iUmPtCyEmTLyvqHNpP8k'' ||'||chr(10)||
'    ''6YTnMwV2GTWZ2UVA52Rax0G5ZMUBv7q+E3U1FSPdIKP1nZt4ZeuhdpmYaUwmk73Z'' ||'||chr(10)||
'    ''bO+RftDDAwnezeJ3WdaSgxoO6zQKJ6PlPB4nk4gpfDy/5yXkMC1MjRoQcjy/l4nf'' ||'||chr(10)||
'    ''HmIqvRhnH5AnU6dJspBfKak7tMynIzo69unAG4XzSVuNwi56iL7nCRs4qOXhFjVB'' ||'||chr(10)||
'    ''HXRUStSkmB3TfwjS7cJIvJXt+AkR2hbFkxqF+/yhLcdoh5bCkASbBmhdbt'||
'GpIdov'' ||'||chr(10)||
'    ''rKQyUF1EutI0vZW25y2bCMyG+ieex9pPJ6CTz5c3ny6/DC02HfC3LUgBrmr2OJnT'' ||'||chr(10)||
'    ''ubMtMro6uWgelaarJO8o9SzIMSAoOfFlr4TGSnrob4jYNFkWp2lhYZdjyVCUMKNm'' ||'||chr(10)||
'    ''M6FGdh6mj2o0tBtjTif5AoBpnOfTaESnqJhatZLYwrhT5rXEcUE8KNNgerKKghBy'' ||'||chr(10)||
'    ''z6REVatMLZOoYZgRTbOovv+dHdMFGl7JqDwaKnTDM1rELN5dkWK10D3S1hhlzzPI'' ||'||chr(10)||
'    ''VowxNnevwnj3Q+nHMHrGYdSki9UwajiENhk+dOGf0EUQXQdQYfb3HeOENRSqqzFn'' ||'||chr(10)||
'    ''yuasOSVQknTp0m'||
'XwmTMrHzQdu72MIxjwhgRmfuEQAIcm/Urmy9ltxL2q9Ctb/kqB'' ||'||chr(10)||
'    ''pFsicquWE9B3oVXzhDa4XV4p2FIyVlzzuJAtz+eiWVOtcIZaHmkJ12fVECpxFVxa'' ||'||chr(10)||
'    ''Zydn/NOqGTp0ogwq2PvPxN7zKhrg1Tdgkizp2rVdUjBaUXxaXdG11ewrGOPtGTcA'' ||'||chr(10)||
'    ''pR4WbMMivdsKdabaStiKmjGi36X2mhrN8qv0mc6QhcOnlsxwCpI0KAqcDQVpj/6P'' ||'||chr(10)||
'    ''lW51W6enexcXe/+mnxabPHkT4FgsRqaLjM/IeGUySpY91NcmFQpv+QHju1tWY3zH'' ||'||chr(10)||
'    ''fXIpuhSV2aMHWigSPnEPE21PqPv8SD0R6lxFadnfYfnR'||
'nPoX1LWgfxQelwcIZNl/'' ||'||chr(10)||
'    ''FUyQAGIzfRaNqSFDWfzfCJTXFcrlH5I0d9eiaZ8mpVo6n9pPVUYV/itz+HQJ5fxF'' ||'||chr(10)||
'    ''49jaBDTK13h/fKsiC/OCDACBJjvTq8oLEVl3EC8YQDgZBCM6qvKQOowp2GKR00oU'' ||'||chr(10)||
'    ''zqxENg87W2v7yYh96WgVQmg8OkujaHQdjT+d6rFGeWd5SCdKuCdA57I9/J71Eash'' ||'||chr(10)||
'    ''u6iLZuEj4ntVbLakQwbdUZ+yi26XfHdhnuRs8ynn+4rzRyRar3kP55PR57vRyQOV'' ||'||chr(10)||
'    ''VLahkjfhvG/SMJ4yZRSlKc9Qfh0zIpry9fGNJVQ1ZZ9TvhYdQhu9zKIJ638mjeym'' ||'||chr(10)||
'    '''||
'cDpNxG6o0BrN56LMqJJPUMNnRm0sLVbFDvTX6aer0XC2yB8NXmJHjLGxlw6cKa9g'' ||'||chr(10)||
'    ''kLhmhe6jlSSwIvElY+0TtSxKXCNXUiIWJUMTGKHzZPwVNZDKV4RYhY/UemUGmV/T'' ||'||chr(10)||
'    ''ZBGlFJ8VZAJFRlUwqFwlVHUbNKanqPAKEB9z+0WaX9eamhntLqJGuQvXzsJp0xXZ'' ||'||chr(10)||
'    ''YFJbsfxD1aS8LpWFO+hnRs9ZuFhxisJ8PTagVf5iCHbqnZxhPPSO8UeMj4fGTo7+'' ||'||chr(10)||
'    ''6pgi3fOeMctQDIpN7+pmkcMuc3tMJ/JsKBYPxgLFXD4wvwIsQO51ulpByOketOjI'' ||'||chr(10)||
'    ''TcolJZgP2V7d8Tnuf7k5w/3zYUuLDh'||
'2bqvKtKqD45EiLLpJvbHlJuo1XoGUIfdwV'' ||'||chr(10)||
'    ''nqMhLfAm5GS8K3Z+JTtqwPjpDluqNDF4onnaDfOYG4a9Q+ZturYp9fKggctd3f6D'' ||'||chr(10)||
'    ''A7rsitFPKOgyn9iWA7hb36mDLc9sJOMjYyp9D1rGVgzs+KgjnVNe3u2q7UqQ/mGt'' ||'||chr(10)||
'    ''AGrfV7L6y5FzKq7GOamzY1yDuTnjLjhTr58KXtb2gNnBojT1iWg3F8bL8q0VoOJf'' ||'||chr(10)||
'    ''6n0s53m7I9BdHzG1jOG9zlq3qudLrvd2Pab479WrXMHWGEhsX+52GU8nDdYqDOr/'' ||'||chr(10)||
'    ''AKgN9GqH1SbdLfroP2IzsVmP4+oelx3+Cvq7WUewFfxefXfsaKDXt/+PMNDr'||
'ul31'' ||'||chr(10)||
'    ''+yvoeLPHCpUUSasG6iROOX+62KdzxE5VIPhj23pMBvVK0HAjvb7HGZe3qN9zrk/g'' ||'||chr(10)||
'    ''1ipfGTKWH8AM5DyO4K61bFiMB/N9yp01jHnYzZqDiy102Sq9VCxt95rb03z53Eji'' ||'||chr(10)||
'    ''A+5TGE3n6xboupmC2ZKiovPHtHQe5dFsQVfj6WNbb0fQtqfLyN6St3ZldtSJGB+s'' ||'||chr(10)||
'    ''GLpPoDmYrLIXtvpsM6R7bgltAcs9VQx3gHv9kC8+pTMMq/fDxSISx/+q09ezCqBJ'' ||'||chr(10)||
'    ''3DKU0XOpjLa0INlRsWyuZbp9yPTyIJV2+LrSDVP/bofWdnCVTI0hXZ7GM2PUc113'' ||'||chr(10)||
'    ''jwJuH1mEjzwvbDVR'||
'XxBZJqThjJq10uD68ek5AjvK9n62sqIlhXh15nTjMeMcMa7x'' ||'||chr(10)||
'    ''YmOwe+uykW1xDxWHXYGRVaoim6h3uKYUf1NF19jEWZ0i8d0ztbYydFITuKPr0XoS'' ||'||chr(10)||
'    ''7o2qukaIDeFNeMuaLpZy+w7GzxanXjqcVcccmhEHRYgpXMzeR3mxdarNgCQhg2aa'' ||'||chr(10)||
'    ''BWjYgW+H3oDtUrIPdQI+fj5Twq8TScMiaOhyuW1u6fMdZ07109lZzzEnNP1YUQZe'' ||'||chr(10)||
'    ''H9AdbEG3s4ms/RKEPR0tpGYQJALR1W6/ZARUS4UCrwpcsTA+cgBsnq09cyDP6igj'' ||'||chr(10)||
'    ''w6jC3UhW/sNRoe+uPcvNVPoYnCYV+vwyAJnmZx0xzoogtO'||
'vrm0IKc74uro4Un3yU'' ||'||chr(10)||
'    ''Lq0I9SKLMnBnFYf04WTCrWqbX0mYl+4LFB99aC8+8BwJiG9E9C2kz9o8bhY9W+gs'' ||'||chr(10)||
'    ''Qs1cl6axdaLsi8XXSfgl9D8fVWFebrNLaBBrZ8fTrAhNdHoWVnCeaedcfoDLPVor'' ||'||chr(10)||
'    ''/q8mipAzcC7VK2MCq6qAszv2KQ+JSnrrhTIOCnFwKUpX76AbQYEbaV5Q8Bk0DdBy'' ||'||chr(10)||
'    ''LKQLm+K7vAUZ67i+m2CEW64zNBxRmKRcRgeoruBciiR1MigpUOM7CwPXnYVBq5m5'' ||'||chr(10)||
'    ''KrAvKYpoKJsunhf9Zvg7x7xurtdkOK6BceDCOFgbY6dxEfPu9hgH6xt/xvhnVArd'' ||'||chr(10)||
'    ''rD'||
'bysqXiCzWW5DA47B+Qw/4mNlN3bmlqrOhcyb1h5zruFTnGYSbPZhxHM+X9cBn2'' ||'||chr(10)||
'    ''bMRLNBrdQjHFmQ2XozQxlLxzY7KggGy6VhwULkj74+cvl6ed678Ph5WLxl1MmiIw'' ||'||chr(10)||
'    ''hTkxkHD58GE7y34gA7Ab3ieoj8ofVAfks5tw+/XnJDLuHdwRNI8+yncEdiF6zZ2J'' ||'||chr(10)||
'    ''ailLs9EO78Y5u3n1xaLDmjtFDkvgvATYtJ8PK/p5/csS7OPcFXzSSxMcE/densMI'' ||'||chr(10)||
'    ''NtXeVVatTFtRloZuQz3GzWctyTBr62+mwZapOzGZhGiTCSLpHaZSX67eaq8Giz2J'' ||'||chr(10)||
'    ''XbQcD8VShcU3f766OP4/MPP+Ls18UGnm'||
'2SXmV2Pf/XVWzKvNfu9Vmv3+M5r9/p/M'' ||'||chr(10)||
'    ''7K/Q5k3svXqKob2Fsa9T6hLKtP1tqqdzSYPy77JXBRg2Hxw+C4sOtwrPZmsUfnys'' ||'||chr(10)||
'    ''LLwb2zz09Kzyr7OntMvqdYu2/rZt2Nl6RmkLjAIC9mFPh78e/zJ8SqTEBnSqr36q'' ||'||chr(10)||
'    ''jWZ+XtXCHjlosQue3kA16nixmEboKpmFlrVju9DzacZHGJ0fRjE1p/xZkOOTq88X'' ||'||chr(10)||
'    ''x5d8k0ZeJTJvQHAFWzGBqllHvTWiidYNWvvv1TvTtoWxY90sZaoMt5WPuYBwcWU8'' ||'||chr(10)||
'    ''1INAQEdjPr0w/KCNsfLdLVQSqnuU7LIdDM0Dy0TdWNBUAIhaW2aos2/txz3NCe'||
'r6'' ||'||chr(10)||
'    ''Z6j2+V7FQedWx5XYM44rOSom6TaCD8+UNbmwq613LfT770Vx+p0mdVW6no0yGekg'' ||'||chr(10)||
'    ''8l0muDlN1Y9ZR7g8lTRX3QKS793sT6JplEdwDL3IiU2TQyVrUdLsOPXJDlRf8HBr'' ||'||chr(10)||
'    ''07nnYMgv9/FbcP+oN8i7OFfi3pO2lBvOyb211lTORTpX9Cdb1L0tBe7qz8Y8VyxE'' ||'||chr(10)||
'    ''qniy4aOMTnHTHjwhUb3Zxs8dRXSZfvGqicfyp8S2OaLUcN9cHDL7fXl+Pbr8cjG8'' ||'||chr(10)||
'    ''+nQyOvn78dXxyc3w6vpov1vaXi+7JlssNz1fD3nK/ePw6sew/79WzWLYV7TBfhWk'' ||'||chr(10)||
'    ''rLh1B90/LESzbngS8F'||
'/emPT14pntvX45P34Wa2I4sCvOi7j7KZxb/sAN28jrykcN'' ||'||chr(10)||
'    ''7C5zXrYXWidUwLpqLx/EscmsNEUvYBArQ7debDQ+/3h8RYax8rz/T9sdr8ZAVsSx'' ||'||chr(10)||
'    ''lbur4g21CjtUkt96s4vvlXw+Hx5fOpB6Ub14Cc3QT42sxPdQ2Xnr8bXW2fH59bBl'' ||'||chr(10)||
'    ''w9y6ufpCU62wRKNHiNUjV1eOFrpOZEoPwLFY5ZurT5e/sH262XIaOgg1nnprQnm9'' ||'||chr(10)||
'    ''A72mF/xcKuSOb3KHTINqozT5Zj+I9HRaWIZUNYO9UL+bZjRQSnczXPHcRQObx0Cr'' ||'||chr(10)||
'    ''Gi8aCa27d0fxwrqftjoFXqEi1WxV+Fkl3M6Te4NG1QARDOoP'||
'W/3Kw1ZIQxpxMaY6'' ||'||chr(10)||
'    ''banVNYZ3veN5Nv7HD9H4K12MX97ws4GESpXyt+PCsXi1J88q2FVElKu2171Nq7rO'' ||'||chr(10)||
'    ''EctcfBrEJj4ZVk1CGDUOFUGcMs+VUVWlAlLX3KHvHKIn9NYCPU2cH38cnj/Tzk95'' ||'||chr(10)||
'    ''0Dl3Z7YOD1wv3H3TmLk/1/7F0xqfnWr3abEXcVVaBf3Q7x/6/QfX77NTrd/cesNb'' ||'||chr(10)||
'    ''kE+m4C+mDc+rC/IBjnxjrgf1Ub2l2MlNleBjoQQXX86f48z2WeM6dfTN0zBzKFqD'' ||'||chr(10)||
'    ''+4AVvPbIGswc4ZOrTHSPR6v8hFg40J6y1l0WwOK40rXVdjI3duuGKr7G7eR43Z3f'' ||'||chr(10)||
'    ''2nNb'||
'Dovf6CT8dW7nNoSjOQg73E513/4qReCu3lRxPc3Cf2lP/mtfmQC/5VV6pkQT'' ||'||chr(10)||
'    ''Uq/1qx2f8o83UlrvaBp/tojV0D/U10bv+KsmXfavjNnikPCfUWz96/xalJ1QFEUA'' ||'||chr(10)||
'    ''V9FKHryFZKU7mjJpIfXmu6g+S35jr8zlCTrRDWpnHYm6HbwIKItYQG2Gyj80ycGx'' ||'||chr(10)||
'    ''pYRBa8xrje/aLHrbQ8broEbTxM+pcdG0BqqC/JcfCx7yQaVRko7ydMkixyOQ23Y0'' ||'||chr(10)||
'    ''sngAX/3uA/tFRd3FKuTNeFmE/aalFdTGcEp1AHxBZ0qHpyxi/5ZaUUiGc6bW76MJ'' ||'||chr(10)||
'    ''Rm2E2Q88MjTv23GXvdFN26zyiJVHQJ5v5f'||
'kgL7DyApDXs/J6IK9v5fVB3oGVdwDy'' ||'||chr(10)||
'    ''BlbeAOQdWnmHRR72zDzsgTwLFwxwwRYuGOCCLVwwwAVbuGCAC7ZwwQAXbOGCAS7Y'' ||'||chr(10)||
'    ''wgUDXLCFCwa4YAsXDHAhFi4E4EIsXAjAhVi4EIALsXAhABdi4UIALsTChQBciIUL'' ||'||chr(10)||
'    ''AbgQCxcCcCEWLgTgQixcCMDFt3DxAS6+hYsPcPEtXHyAi2/h4gNcfAsXH+DiW7j4'' ||'||chr(10)||
'    ''ABffwsUHuPgWLj7Axbdw8QEuvoWLD3AJLFwCgEtg4RIAXAILlwDgEli4BACXwMIl'' ||'||chr(10)||
'    ''ALgEFi4BwCWwcAkALoGFSwBwCSxcAoBLYOESAFx6Fi49z7yBERlLBzEsVY1Wy1wy'||
''' ||'||chr(10)||
'    ''VP3mVnmSYk8ZzCK2PsocU9Ib9ltNY8/D7HeKizlAJROYTHSyD5N9nRzA5EAn92By'' ||'||chr(10)||
'    ''Tyf3YXJfJx/A5AOdPIDJA518CJMPVTL2QDI14yoZSom1lBhKibWUGEqJtZQYSom1'' ||'||chr(10)||
'    ''lBhKibWUGEqJtZQYSom1lBhKibWUGEqJtZQESkm0lARKSbSUBEpJtJQESkm0lARK'' ||'||chr(10)||
'    ''SbSUBEpJtJQESkm0lARKSbSUBEpJtJQESkm0lD6U0tdS+lBKX0vpQyl9LaUPpfS1'' ||'||chr(10)||
'    ''lD6U0tdS+lBKX0vpQyl9LaUPpfS1lD6U0tdS+lBKX0sZQCkDLWUApQy0lAGUMtBS'' ||'||chr(10)||
'    ''BlDKQEsZQCkDLWUApQy0'||
'lAGUMtBSBlDKQEsZQCkDLWUApQy0lD0oJTV/bzrmrSDT'' ||'||chr(10)||
'    ''mul1eTRxewzMzfkf5U6pzm5/AAA='';'||chr(10)||
'--'||chr(10)||
'  procedure log( p_msg varchar2 )'||chr(10)||
'  is'||chr(10)||
'  begin'||chr(10)||
'--    apex_debug_message.error( p_msg );'||chr(10)||
'    apex_debug_message.log_message( p_msg, p_level => 4 );'||chr(10)||
'  end;'||chr(10)||
'--'||chr(10)||
'begin'||chr(10)||
'  p_browse_item     := p_process.attribute_01;'||chr(10)||
'  p_collection_name := p_process.attribute_02;'||chr(10)||
'  p_sheet_nrs       := p_process.attribute_03;'||chr(10)||
'  if upp'||
'er( p_process.attribute_04 ) in ( ''HT'', ''^I'', ''\T'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(9);'||chr(10)||
'  elsif upper( p_process.attribute_04 ) in ( ''VT'', ''^K'', ''\V'' )'||chr(10)||
'  then'||chr(10)||
'    p_separator := chr(11);'||chr(10)||
'  else'||chr(10)||
'    p_separator := substr( ltrim( p_process.attribute_04 ), 1, 1 );'||chr(10)||
'  end if;'||chr(10)||
'  p_enclosed_by     := substr( ltrim( p_process.attribute_05 ), 1, 1 );'||chr(10)||
'  p_encoding        := p_process.attribute_06;'||chr(10)||
'--'||chr(10)||
'  t_fil'||
'ename := apex_util.get_session_state(  p_browse_item );'||chr(10)||
'  log( ''looking for uploaded file '' || t_filename );'||chr(10)||
'--'||chr(10)||
'  begin'||chr(10)||
'    select aaf.id'||chr(10)||
'         , aaf.blob_content'||chr(10)||
'         , aaf.filename'||chr(10)||
'    into t_file_id'||chr(10)||
'       , t_document'||chr(10)||
'       , t_filename'||chr(10)||
'    from apex_application_files aaf'||chr(10)||
'    where aaf.name = t_filename;'||chr(10)||
'--'||chr(10)||
'    delete from apex_application_files aaf'||chr(10)||
'    where aaf.id = t_file_id;'||chr(10)||
'--'||chr(10)||
'   '||
' log( ''retrieved!''  );'||chr(10)||
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
'    log( ''file with length '' || dbms_lob.getlength( t_document ) || '' found '' );'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'  if apex_collection.collection_exists( p_collection_name )'||chr(10)||
'  then'||chr(10)||
'    apex_collecti'||
'on.delete_collection( p_collection_name );'||chr(10)||
'  end if;'||chr(10)||
'  for i in 1 .. 10'||chr(10)||
'  loop'||chr(10)||
'    if apex_collection.collection_exists( p_collection_name || i )'||chr(10)||
'    then'||chr(10)||
'      apex_collection.delete_collection( p_collection_name || i );'||chr(10)||
'    end if;'||chr(10)||
'  end loop;'||chr(10)||
'--'||chr(10)||
'  if dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''504B0304'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLSX'' );'||chr(10)||
'    t_what := ''XLSX-file'';'||chr(10)||
'    t_parse := utl_raw.c'||
'ast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xlsx ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  elsif dbms_lob.substr( t_document, 8, 1 ) = hextoraw( ''D0CF11E0A1B11AE1'' )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XLS'' );'||chr(10)||
'    t_what := ''XLS-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( u'||
'tl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xls ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  elsif (  dbms_lob.substr( t_document, 1, 1 ) = hextoraw( ''3C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 2, 1 ) = hextoraw( ''003C'' )'||chr(10)||
'        or dbms_lob.substr( t_document, 4, 1 ) = hextoraw( ''0000003C'' )'||chr(10)||
'        )'||chr(10)||
'  then'||chr(10)||
'    log( ''parsing XML'' );'||chr(10)||
'    '||
't_what := ''XML-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw.cast_to_raw( t_parse_xml ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_sheet_nrs;'||chr(10)||
'  else'||chr(10)||
'    log( ''parsing CSV'' );'||chr(10)||
'    t_what := ''CSV-file'';'||chr(10)||
'    t_parse := utl_raw.cast_to_varchar2( utl_compress.lz_uncompress( utl_encode.base64_decode( utl_raw'||
'.cast_to_raw( t_parse_csv ) ) ) );'||chr(10)||
'    execute immediate t_parse using p_collection_name, t_document, p_separator, p_enclosed_by, p_encoding;'||chr(10)||
'  end if;'||chr(10)||
'--'||chr(10)||
'    t_rv.success_message := ''Loaded a '' || t_what || '' in '' || to_char( trunc( ( sysdate - t_time ) * 24 * 60 * 60 ) ) || '' seconds'';'||chr(10)||
'    return t_rv;'||chr(10)||
'exception'||chr(10)||
'  when e_no_doc'||chr(10)||
'  then'||chr(10)||
'    t_rv.success_message := ''No uploaded document found'';'||chr(10)||
'   '||
' return t_rv;'||chr(10)||
'  when others'||chr(10)||
'  then'||chr(10)||
'    log( dbms_utility.format_error_stack );'||chr(10)||
'    log( dbms_utility.format_error_backtrace );'||chr(10)||
'    t_rv.success_message := ''Oops, something went wrong in '' || p_plugin.name ||'||chr(10)||
'         ''<br/>'' || dbms_utility.format_error_stack || ''<br/><br/>'' ||'||chr(10)||
'       dbms_utility.format_error_backtrace || ''<br/><br/>'' ||'||chr(10)||
'         ''This could be caused by<ul>'' ||'||chr(10)||
'           ''<li>'''||
' || ''my (lack of) programming skills'' || ''</li>'' ||'||chr(10)||
'           ''<li>'' || ''something else, people do a lot more with Apex than I ever could imagine''||'||chr(10)||
'           ''</li></ul><br/>'' ||'||chr(10)||
'           ''try running this plugin in debug mode, and send the debug messages to me, scheffer@amis.nl'';'||chr(10)||
'    return t_rv;'||chr(10)||
'end;'||chr(10)||
''
 ,p_execution_function => 'parse_excel'
 ,p_version_identifier => '0.804'
 ,p_plugin_comment => '0.804'||chr(10)||
'  XLSX: Fix bug for formated strings'||chr(10)||
'  CSV: Support for HT separator'||chr(10)||
'0.802'||chr(10)||
'  XLSX: Support for numbers in scientific notation'||chr(10)||
'  XLSX: Fix bug for empty strings'||chr(10)||
''
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1817805590042565 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 1
 ,p_display_sequence => 10
 ,p_prompt => 'Browse Item'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_is_translatable => false
 ,p_help_text => 'The name of the File Browse Item which is used to select the uploaded Excel file.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1818503212070294 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 2
 ,p_display_sequence => 20
 ,p_prompt => 'Collection name'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => true
 ,p_is_translatable => false
 ,p_help_text => 'The name of the Collection in which the first sheet is placed.'||chr(10)||
'<br/>Eventually, other sheets are placed in Colections with a sequence number attached to this name: <br/>'||chr(10)||
'<br/>&lt;Collection name&gt;2'||chr(10)||
'<br/>&lt;Collection name&gt;3'||chr(10)||
'<br/>&lt;Collection name&gt;4'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1819817804102853 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 3
 ,p_display_sequence => 30
 ,p_prompt => 'Sheets'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'A colon separated list of sheets which should loaded.'||chr(10)||
'<br/>When left empty all sheets are loaded.<br/>'||chr(10)||
'A sheet is identified by its name or positional number.'||chr(10)||
'<br/><br/>For instance'||chr(10)||
'<br/>'||chr(10)||
'&nbsp;&nbsp;1:3 will load the first and the third sheet<br/>'||chr(10)||
'&nbsp;&nbsp;Sheet1:Sheet2 will load the sheets with the names "Sheet1" and  "Sheet2"'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1820522006132483 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 4
 ,p_display_sequence => 40
 ,p_prompt => 'CSV Separator'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_default_value => ';'
 ,p_is_translatable => false
 ,p_help_text => 'The column separator character used for CSV-files.<br/>'||chr(10)||
'Use \t, ^I or HT for a (horizontal) tab character.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1821219844150737 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 5
 ,p_display_sequence => 50
 ,p_prompt => 'CSV Enclosed By'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_default_value => '"'
 ,p_is_translatable => false
 ,p_help_text => 'A delimiter character used for CSV-files. This character is used to delineate the starting and ending boundary of a data value.'||chr(10)||
'The default value is ".'||chr(10)||
'The same character is used as the escape character.'
  );
wwv_flow_api.create_plugin_attribute (
  p_id => 1821914135186965 + wwv_flow_api.g_id_offset
 ,p_flow_id => wwv_flow.g_flow_id
 ,p_plugin_id => 1773328202295537 + wwv_flow_api.g_id_offset
 ,p_attribute_scope => 'COMPONENT'
 ,p_attribute_sequence => 6
 ,p_display_sequence => 60
 ,p_prompt => 'CSV Character set'
 ,p_attribute_type => 'TEXT'
 ,p_is_required => false
 ,p_is_translatable => false
 ,p_help_text => 'The character set used for loading a CSV file.'||chr(10)||
'<br/>When left empty the database character set is used.'||chr(10)||
'<br/>Use the Oracle name for the character set, for instance WE8MSWIN1252 and not Windows-1252'
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
