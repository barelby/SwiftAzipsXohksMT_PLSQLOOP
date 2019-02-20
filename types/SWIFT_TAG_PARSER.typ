create or replace type SWIFT_TAG_PARSER FORCE AS OBJECT
(
    block4_source   CLOB,
    -- Попытаться переести на hasmap
    tags            ibs.t_string_collection,
    tags_value      ibs.t_clob_collection,
    MEMBER PROCEDURE fill_tag_field,
    MEMBER FUNCTION get_tags_parser_regexp RETURN VARCHAR ,
    MEMBER FUNCTION get_block4_regexp RETURN VARCHAR2 ,
    MEMBER PROCEDURE update_block4_source(p_block4 CLOB) ,
    MEMBER FUNCTION isset_tag(p_tag_name varchar) RETURN BOOLEAN,
    MEMBER FUNCTION get_tag_value(p_tag_name varchar, p_raise BOOLEAN DEFAULT TRUE) RETURN CLOB,
    CONSTRUCTOR FUNCTION SWIFT_TAG_PARSER(p_block4 CLOB) RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION SWIFT_TAG_PARSER RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body SWIFT_TAG_PARSER AS
    
    MEMBER FUNCTION get_block4_regexp RETURN VARCHAR2 IS
    BEGIN RETURN '\{4:\s*([^{}]+)\s*\-\}'; END;
    
    MEMBER FUNCTION get_tags_parser_regexp RETURN VARCHAR IS
    BEGIN RETURN ':([0-9a-zA-Z]*):(.*[^:.:]*)'; END;
    
    MEMBER FUNCTION isset_tag(p_tag_name varchar) RETURN BOOLEAN IS
        l_tag_indx  INTEGER;
    BEGIN
        l_tag_indx := SELF.TAGS.FIRST;
        WHILE l_tag_indx IS NOT NULL
        LOOP
            IF SELF.TAGS(l_tag_indx) = p_tag_name THEN RETURN TRUE; END IF;
            l_tag_indx := SELF.TAGS.NEXT(l_tag_indx);
        END LOOP;
        RETURN FALSE;
    END;
    
    MEMBER FUNCTION get_tag_value(p_tag_name varchar, p_raise BOOLEAN DEFAULT TRUE) RETURN CLOB IS
        l_tag_indx  INTEGER;
        l_value     CLOB DEFAULT NULL;
    BEGIN
        l_tag_indx := SELF.TAGS.FIRST;
        WHILE l_tag_indx IS NOT NULL
        LOOP
            IF SELF.TAGS(l_tag_indx) = p_tag_name THEN
                l_value := SELF.TAGS_VALUE(l_tag_indx);
                EXIT; 
            END IF;
            l_tag_indx := SELF.TAGS.NEXT(l_tag_indx);
        END LOOP;
        IF l_value IS NULL THEN raise_application_error(-20000, 'Тег не найден'); END IF;
        RETURN l_value;
    EXCEPTION WHEN OTHERS THEN 
        IF p_raise THEN RAISE; END IF;
        RETURN NULL;
    END;    
    
    MEMBER PROCEDURE fill_tag_field IS
        l_tags_coll ibs.t_clob_collection;
        l_tag_indx  INTEGER;
        l_val       CLOB;
    BEGIN
        IF SELF.TAGS IS NULL THEN SELF.TAGS := ibs.t_string_collection();
        ELSE SELF.TAGS.delete();
        END IF;
        
        IF SELF.TAGS_VALUE IS NULL THEN SELF.TAGS_VALUE := ibs.t_clob_collection();
        ELSE SELF.TAGS_VALUE.delete();
        END IF;
        
        l_tags_coll := ibs.regexp_match_clob_collection(get_tags_parser_regexp, SELF.BLOCK4_SOURCE);
        l_tag_indx := l_tags_coll.FIRST;
        WHILE l_tag_indx IS NOT NULL
        LOOP
            IF MOD(l_tag_indx, 2) > 0 THEN
                SELF.TAGS.extend;
                SELF.TAGS(SELF.TAGS.LAST) := l_tags_coll(l_tag_indx);
            ELSE 
                SELF.TAGS_VALUE.extend;
                l_val := jui_interbankpayments_tools.TRIMMING(l_tags_coll(l_tag_indx));
                SELF.TAGS_VALUE(SELF.TAGS_VALUE.LAST) := CASE WHEN LENGTH(l_val) = 0 THEN NULL ELSE l_val END;
            END IF;
            l_tag_indx := l_tags_coll.NEXT(l_tag_indx);
        END LOOP;
        
        l_tag_indx := SELF.TAGS.FIRST;
        WHILE l_tag_indx IS NOT NULL
        LOOP
            l_tag_indx := SELF.TAGS.NEXT(l_tag_indx);
        END LOOP;
    END;

    MEMBER PROCEDURE update_block4_source(p_block4 CLOB) IS
        l_coll      ibs.t_clob_collection;
        
    BEGIN 
        l_coll := ibs.regexp_match_clob_collection(get_block4_regexp, p_block4);
        IF l_coll IS NULL OR l_coll.count = 0 THEN
            raise_application_error(-20000, 'Блок 4 имеет не правильный формат: ' || chr(10) ||p_block4);
        END IF;
        SELF.BLOCK4_SOURCE := l_coll(l_coll.FIRST);
        fill_tag_field();
    END;

    CONSTRUCTOR FUNCTION SWIFT_TAG_PARSER(p_block4 CLOB) RETURN SELF AS RESULT 
    IS BEGIN update_block4_source(p_block4); RETURN; END;
    
    CONSTRUCTOR FUNCTION SWIFT_TAG_PARSER RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
    
    
end;
/
