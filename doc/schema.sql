--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'KOI8R';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: nz; Type: DATABASE; Schema: -; Owner: nz
--

CREATE DATABASE nz WITH TEMPLATE = template0 ENCODING = 'KOI8';


\connect nz

SET statement_timeout = 0;
SET client_encoding = 'KOI8R';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: auction; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE auction (
    topic_id integer NOT NULL,
    id integer NOT NULL,
    name character varying(100),
    start_price numeric(12,2) NOT NULL,
    current_price numeric(12,2) NOT NULL,
    step_price numeric(12,0) DEFAULT 50 NOT NULL,
    is_closed boolean DEFAULT false NOT NULL,
    last_user_id integer,
    comment text
);


ALTER TABLE public.auction OWNER TO nz;

--
-- Name: auction_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE auction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.auction_id_seq OWNER TO nz;

--
-- Name: auction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE auction_id_seq OWNED BY auction.id;


--
-- Name: auction_steps; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE auction_steps (
    auction_id integer NOT NULL,
    user_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    new_price numeric(12,2) NOT NULL,
    comment character varying(255)
);


ALTER TABLE public.auction_steps OWNER TO nz;

--
-- Name: banner; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE banner (
    id integer NOT NULL,
    file character varying(255),
    user_id integer,
    date_from timestamp without time zone DEFAULT now() NOT NULL,
    date_to timestamp without time zone,
    rank integer DEFAULT 1 NOT NULL,
    ranker bigint DEFAULT 0 NOT NULL,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_removed boolean DEFAULT false NOT NULL,
    type character varying(10) NOT NULL,
    link character varying(255),
    size bigint NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    counter bigint DEFAULT 0 NOT NULL,
    comment character varying(255),
    last_time timestamp without time zone
);


ALTER TABLE public.banner OWNER TO nz;

--
-- Name: banner_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE banner_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.banner_id_seq OWNER TO nz;

--
-- Name: banner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE banner_id_seq OWNED BY banner.id;


--
-- Name: banner_log; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE banner_log (
    banner_id integer NOT NULL,
    ip inet NOT NULL,
    session character varying(100),
    site_id integer,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.banner_log OWNER TO nz;

--
-- Name: banners_display; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE banners_display (
    id integer NOT NULL,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    last_time timestamp without time zone,
    date_to date,
    link character varying(255),
    file character varying(255) NOT NULL,
    type character varying(10) DEFAULT 'flash'::character varying NOT NULL,
    "position" character varying(10) DEFAULT 'top'::character varying NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    counter bigint DEFAULT 0 NOT NULL,
    banner_id integer NOT NULL,
    user_id integer
);


ALTER TABLE public.banners_display OWNER TO nz;

--
-- Name: banners_display_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE banners_display_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.banners_display_id_seq OWNER TO nz;

--
-- Name: banners_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE banners_display_id_seq OWNED BY banners_display.id;


--
-- Name: banners_log; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE banners_log (
    counter bigint DEFAULT 0 NOT NULL,
    "position" character varying(100) NOT NULL,
    date_from date NOT NULL,
    date_to date DEFAULT now() NOT NULL,
    banner_id integer NOT NULL,
    active_user_id integer,
    deactive_user_id integer
);


ALTER TABLE public.banners_log OWNER TO nz;

--
-- Name: blacks; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE blacks (
    user_id integer NOT NULL,
    black_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    comment character varying(255)
);


ALTER TABLE public.blacks OWNER TO nz;

--
-- Name: city; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE city (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.city OWNER TO nz;

--
-- Name: city_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE city_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.city_id_seq OWNER TO nz;

--
-- Name: city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE city_id_seq OWNED BY city.id;


--
-- Name: click_counter; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE click_counter (
    host character varying(255) NOT NULL,
    path text DEFAULT ''::character varying NOT NULL,
    query text DEFAULT ''::character varying NOT NULL,
    referer text DEFAULT ''::character varying NOT NULL,
    counter bigint DEFAULT 1 NOT NULL,
    first_time timestamp without time zone DEFAULT now() NOT NULL,
    last_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.click_counter OWNER TO nz;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE comment (
    id integer NOT NULL,
    create_ip inet NOT NULL,
    change_ip inet,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    topic_id integer NOT NULL,
    parent_user_id integer NOT NULL,
    parent_id integer,
    text text NOT NULL,
    sign character varying(255),
    user_id integer NOT NULL,
    file_id integer,
    vote_id integer,
    videos_looked boolean DEFAULT false NOT NULL
);


ALTER TABLE public.comment OWNER TO nz;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE comment_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.comment_id_seq OWNER TO nz;

--
-- Name: comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE comment_id_seq OWNED BY comment.id;


--
-- Name: file_rating; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE file_rating (
    user_id integer NOT NULL,
    file_id integer NOT NULL,
    rating integer DEFAULT 0 NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.file_rating OWNER TO nz;

--
-- Name: files_persons; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE files_persons (
    timsstamp timestamp without time zone DEFAULT now() NOT NULL,
    file_id integer NOT NULL,
    user_id integer NOT NULL,
    comment character varying(255)
);


ALTER TABLE public.files_persons OWNER TO nz;

--
-- Name: filesholder_dir; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE filesholder_dir (
    id integer NOT NULL,
    user_id integer NOT NULL,
    path character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    comment text,
    parent_id integer,
    is_hidden boolean DEFAULT false NOT NULL,
    subdirs integer DEFAULT 0 NOT NULL,
    files integer DEFAULT 0 NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    topic_id integer
);


ALTER TABLE public.filesholder_dir OWNER TO nz;

--
-- Name: filesholder_dir_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE filesholder_dir_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.filesholder_dir_id_seq OWNER TO nz;

--
-- Name: filesholder_dir_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE filesholder_dir_id_seq OWNED BY filesholder_dir.id;


--
-- Name: filesholder_file; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE filesholder_file (
    id integer NOT NULL,
    dir_id integer NOT NULL,
    path character varying(255) NOT NULL,
    file character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    comment text,
    type character varying(10) DEFAULT 0 NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
    views integer DEFAULT 0 NOT NULL,
    thumb_width integer,
    thumb_height integer,
    thumb_file character varying(200),
    thumb_size bigint DEFAULT 0 NOT NULL,
    gallery_file character varying(255),
    gallery_width integer DEFAULT 0 NOT NULL,
    gallery_height integer DEFAULT 0 NOT NULL,
    gallery_size bigint DEFAULT 0 NOT NULL,
    src_file character varying(255) NOT NULL,
    src_size bigint DEFAULT 0 NOT NULL,
    title character varying(255),
    media_width integer,
    media_height integer,
    length_secs bigint,
    media_artist character varying(255),
    media_track character varying(255),
    media_album character varying(255),
    media_year character varying(255),
    media_genre character varying(255),
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    user_id integer NOT NULL,
    link_id integer,
    linked text DEFAULT ''::text NOT NULL,
    is_moderated boolean DEFAULT false NOT NULL,
    is_in_gallery boolean DEFAULT false NOT NULL,
    topic_id integer,
    topic_subject character varying(255),
    comments integer DEFAULT 0 NOT NULL,
    last_comment_time timestamp without time zone,
    last_comment_id integer,
    media_title character varying(255),
    media_info text,
    rating_summa bigint DEFAULT 0 NOT NULL,
    raters integer DEFAULT 0 NOT NULL,
    rating numeric DEFAULT 0 NOT NULL,
    rating_total bigint DEFAULT 0 NOT NULL,
    is_on_main boolean DEFAULT false NOT NULL
);


ALTER TABLE public.filesholder_file OWNER TO nz;

--
-- Name: filesholder_file_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE filesholder_file_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.filesholder_file_id_seq OWNER TO nz;

--
-- Name: filesholder_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE filesholder_file_id_seq OWNED BY filesholder_file.id;


--
-- Name: friends; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE friends (
    user_id integer NOT NULL,
    friend_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    comment character varying(255)
);


ALTER TABLE public.friends OWNER TO nz;

--
-- Name: fuser; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE fuser (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    login character varying(255) NOT NULL,
    password character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(100) NOT NULL,
    email_changed timestamp without time zone,
    email_checked timestamp without time zone,
    mobile_changed timestamp without time zone,
    mobile_checked timestamp without time zone,
    sign_ip inet NOT NULL,
    last_ip inet NOT NULL,
    lasttime timestamp without time zone DEFAULT now() NOT NULL,
    session character(32) NOT NULL,
    sessiontime timestamp without time zone DEFAULT now() NOT NULL,
    city_id integer NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    new_mail integer DEFAULT 0 NOT NULL,
    new_mail_timestamp timestamp without time zone,
    is_logged boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_removed boolean DEFAULT false NOT NULL,
    remove_comment character varying,
    topics bigint DEFAULT 0 NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    sign character varying(255),
    hide_mat boolean DEFAULT true NOT NULL,
    image_time timestamp without time zone,
    image_file character varying(255),
    image_width integer DEFAULT 0 NOT NULL,
    image_height integer DEFAULT 0 NOT NULL,
    thumb_time timestamp without time zone,
    thumb_file character varying(255),
    thumb_width integer DEFAULT 0 NOT NULL,
    thumb_height integer DEFAULT 0 NOT NULL,
    is_academic boolean DEFAULT false NOT NULL,
    pips integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    last_topics_view timestamp without time zone,
    client_id integer,
    is_worker boolean DEFAULT false NOT NULL,
    signer_id integer,
    mobile_code character varying(12),
    email_code character varying(12),
    address text,
    mobile character varying(20),
    mobile_tries integer DEFAULT 0 NOT NULL,
    email_tries integer DEFAULT 0 NOT NULL,
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    show_private boolean DEFAULT false NOT NULL,
    new_answers_time timestamp without time zone,
    answers integer DEFAULT 0 NOT NULL,
    new_answers integer DEFAULT 0 NOT NULL,
    admin_comment character varying(255),
    comment text,
    fresh_topics integer DEFAULT 0 NOT NULL,
    blacked integer DEFAULT 0 NOT NULL,
    friended integer DEFAULT 0 NOT NULL,
    icon character varying(15) DEFAULT ''::character varying NOT NULL,
    web_community character varying(100) DEFAULT 'zhazhda'::character varying NOT NULL,
    draft_topics integer DEFAULT 0 NOT NULL,
    use_smile boolean DEFAULT false NOT NULL,
    auto_password character varying(100),
    remove_user_id integer,
    user_agent text,
    filter character varying(255) DEFAULT ''::character varying NOT NULL,
    banners integer DEFAULT 0 NOT NULL,
    banners_limit integer DEFAULT 0 NOT NULL,
    block_type integer DEFAULT 0 NOT NULL,
    block_time timestamp without time zone,
    block_comment text,
    domain character varying(50),
    podcast_name character varying(255),
    podcast_comment text,
    podcast_type integer DEFAULT 0 NOT NULL,
    podcast_files integer DEFAULT 0 NOT NULL,
    karma bigint DEFAULT 0 NOT NULL,
    is_fotocor boolean DEFAULT false NOT NULL,
    top_limits integer DEFAULT 0 NOT NULL,
    top_limit integer DEFAULT 0 NOT NULL,
    banner_admin boolean DEFAULT false,
    sms_subscribe boolean DEFAULT false NOT NULL,
    sms_event_type integer DEFAULT 0 NOT NULL,
    autoplay boolean DEFAULT true NOT NULL,
    is_advisor boolean DEFAULT false NOT NULL,
    CONSTRAINT fuser_answers_check CHECK ((answers >= 0)),
    CONSTRAINT fuser_blacked_check CHECK ((blacked >= 0)),
    CONSTRAINT fuser_draft_topics_check CHECK ((draft_topics >= 0)),
    CONSTRAINT fuser_friended_check CHECK ((friended >= 0)),
    CONSTRAINT fuser_new_answers_check CHECK (((new_answers >= 0) AND (new_answers <= answers))),
    CONSTRAINT fuser_new_mail_check CHECK ((new_mail >= 0)),
    CONSTRAINT fuser_new_subscribe_topics_check CHECK ((fresh_topics >= 0))
);


ALTER TABLE public.fuser OWNER TO nz;

--
-- Name: fuser_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE fuser_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.fuser_id_seq OWNER TO nz;

--
-- Name: fuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE fuser_id_seq OWNED BY fuser.id;


--
-- Name: journal; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE journal (
    id integer NOT NULL,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    changed_time timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    user_id integer NOT NULL,
    access_journal integer DEFAULT 1 NOT NULL,
    access_topic integer DEFAULT 1 NOT NULL,
    access_comment integer DEFAULT 1 NOT NULL,
    access_cross integer DEFAULT 1 NOT NULL,
    moderating integer DEFAULT 0 NOT NULL,
    topics bigint DEFAULT 0 NOT NULL,
    comments bigint DEFAULT 0 NOT NULL,
    last_topic_time timestamp without time zone,
    last_comment_time timestamp without time zone,
    list_order integer,
    class character varying(100),
    templ_path character varying(50) DEFAULT 'default'::character varying NOT NULL,
    host character varying(100) DEFAULT '*'::character varying NOT NULL,
    days_to_list integer DEFAULT 7,
    path character varying(200),
    comment_list_mode integer DEFAULT 1 NOT NULL,
    respect_links text,
    topic_list_mode integer DEFAULT 0 NOT NULL,
    categories integer DEFAULT 0 NOT NULL,
    access_topic_status integer DEFAULT 0 NOT NULL,
    top_days_to_list integer DEFAULT 7,
    min_raters integer DEFAULT 5 NOT NULL,
    hot_days integer DEFAULT 7,
    hot_nonew_days integer DEFAULT 2,
    is_active boolean DEFAULT false NOT NULL,
    CONSTRAINT journal_comment_list_mode_check CHECK (((comment_list_mode >= 1) AND (comment_list_mode <= 2))),
    CONSTRAINT journal_topic_list_mode_check CHECK ((topic_list_mode >= 0))
);


ALTER TABLE public.journal OWNER TO nz;

--
-- Name: journal_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE journal_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.journal_id_seq OWNER TO nz;

--
-- Name: journal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE journal_id_seq OWNED BY journal.id;


--
-- Name: journal_issue; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE journal_issue (
    id integer NOT NULL,
    journal_id integer NOT NULL,
    number integer NOT NULL,
    title character varying(100) NOT NULL,
    description text,
    first_date date NOT NULL,
    last_date date NOT NULL,
    topics integer DEFAULT 0 NOT NULL,
    prev_id integer,
    next_id integer,
    CONSTRAINT journal_issue_check CHECK ((first_date <= last_date)),
    CONSTRAINT journal_issue_check1 CHECK ((last_date >= first_date)),
    CONSTRAINT journal_issue_topics_check CHECK ((topics >= 0))
);


ALTER TABLE public.journal_issue OWNER TO nz;

--
-- Name: journal_issue_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE journal_issue_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.journal_issue_id_seq OWNER TO nz;

--
-- Name: journal_issue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE journal_issue_id_seq OWNED BY journal_issue.id;


--
-- Name: journal_members; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE journal_members (
    journal_id integer NOT NULL,
    user_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    added_user_id integer NOT NULL
);


ALTER TABLE public.journal_members OWNER TO nz;

--
-- Name: journal_topic; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE journal_topic (
    journal_id integer NOT NULL,
    topic_id integer NOT NULL,
    is_owner boolean DEFAULT false NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    is_on_top boolean DEFAULT false NOT NULL,
    category_id integer,
    sticky_date date,
    is_red boolean DEFAULT false NOT NULL,
    is_bold boolean DEFAULT false NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    show_text integer DEFAULT 0 NOT NULL,
    image_mode integer DEFAULT 0 NOT NULL,
    image_id integer,
    image_time timestamp without time zone,
    short_text character varying(255),
    is_hot boolean DEFAULT false NOT NULL,
    is_cold boolean DEFAULT false NOT NULL,
    is_on_main boolean DEFAULT true NOT NULL,
    was_top boolean DEFAULT false NOT NULL,
    was_hot boolean DEFAULT false NOT NULL
);


ALTER TABLE public.journal_topic OWNER TO nz;

--
-- Name: journal_views; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE journal_views (
    journal_id integer NOT NULL,
    user_id integer NOT NULL,
    last_topic_time timestamp without time zone DEFAULT now() NOT NULL,
    new_topics integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.journal_views OWNER TO nz;

--
-- Name: mail; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE mail (
    id integer NOT NULL,
    user_id integer NOT NULL,
    talker_id integer NOT NULL,
    createtime timestamp without time zone DEFAULT now() NOT NULL,
    is_inbox boolean DEFAULT false NOT NULL,
    is_shown boolean DEFAULT false NOT NULL,
    showtime timestamp without time zone,
    message text
);


ALTER TABLE public.mail OWNER TO nz;

--
-- Name: mail_box; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE mail_box (
    user_id integer NOT NULL,
    talker_id integer NOT NULL,
    outcomings integer DEFAULT 0 NOT NULL,
    incomings integer DEFAULT 0 NOT NULL,
    new_mail integer DEFAULT 0 NOT NULL,
    last_view timestamp without time zone,
    last_incoming timestamp without time zone,
    last_outcoming timestamp without time zone,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT mail_box_new_mail_check CHECK ((new_mail >= 0))
);


ALTER TABLE public.mail_box OWNER TO nz;

--
-- Name: mail_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE mail_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.mail_id_seq OWNER TO nz;

--
-- Name: mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE mail_id_seq OWNED BY mail.id;


--
-- Name: main_topics; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE main_topics (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    create_time timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    subject character varying(250) NOT NULL,
    text text NOT NULL,
    journal_id integer NOT NULL,
    topic_id integer NOT NULL,
    is_hot boolean DEFAULT false NOT NULL,
    comments integer DEFAULT 0 NOT NULL,
    last_comment_time timestamp without time zone,
    last_comment_id integer
);


ALTER TABLE public.main_topics OWNER TO nz;

--
-- Name: main_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE main_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.main_topics_id_seq OWNER TO nz;

--
-- Name: main_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE main_topics_id_seq OWNED BY main_topics.id;


--
-- Name: place; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE place (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    place_category_id integer NOT NULL,
    city_id integer,
    is_moderated boolean DEFAULT false NOT NULL
);


ALTER TABLE public.place OWNER TO nz;

--
-- Name: place2; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE place2 (
    id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    city_id integer NOT NULL,
    user_id integer NOT NULL,
    category_id integer NOT NULL,
    is_moderated boolean DEFAULT false NOT NULL,
    is_removed boolean DEFAULT false NOT NULL,
    address character varying(255) NOT NULL,
    name character varying(255),
    comment character varying(255),
    image_file character varying(100),
    image_width integer DEFAULT 0 NOT NULL,
    image_height integer DEFAULT 0 NOT NULL,
    thumb_file character varying(100),
    thumb_width integer DEFAULT 0 NOT NULL,
    thumb_height integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.place2 OWNER TO nz;

--
-- Name: place2_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE place2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.place2_id_seq OWNER TO nz;

--
-- Name: place2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE place2_id_seq OWNED BY place2.id;


--
-- Name: place_category; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE place_category (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.place_category OWNER TO nz;

--
-- Name: place_category_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE place_category_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.place_category_id_seq OWNER TO nz;

--
-- Name: place_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE place_category_id_seq OWNED BY place_category.id;


--
-- Name: place_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE place_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.place_id_seq OWNER TO nz;

--
-- Name: place_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE place_id_seq OWNED BY place.id;


--
-- Name: sign_code; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE sign_code (
    user_id integer NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    code character varying(16) NOT NULL,
    signer_id integer
);


ALTER TABLE public.sign_code OWNER TO nz;

--
-- Name: topic; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic (
    id integer NOT NULL,
    create_ip inet NOT NULL,
    change_ip inet,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    subject character varying(255) NOT NULL,
    text text,
    sign character varying(255),
    user_id integer NOT NULL,
    comments integer DEFAULT 0 NOT NULL,
    commentators integer DEFAULT 0 NOT NULL,
    last_comment_time timestamp without time zone,
    last_comment_id integer,
    journals integer DEFAULT 0 NOT NULL,
    link_topic_id integer,
    link_journal_id integer,
    dir_id integer,
    topic_type character varying(50) DEFAULT ''::character varying NOT NULL,
    vote_access integer,
    movies integer DEFAULT 0 NOT NULL,
    music integer DEFAULT 0 NOT NULL,
    images integer DEFAULT 0 NOT NULL,
    subscribers integer DEFAULT 0 NOT NULL,
    gallery_type integer DEFAULT 0 NOT NULL,
    is_removed boolean DEFAULT false NOT NULL,
    is_closed boolean DEFAULT false NOT NULL,
    pipers integer DEFAULT 0 NOT NULL,
    pips_summ integer DEFAULT 0 NOT NULL,
    event_date date,
    event_time time without time zone,
    place_id integer,
    votes integer DEFAULT 0 NOT NULL,
    files integer DEFAULT 0 NOT NULL,
    description character varying(255),
    views bigint DEFAULT 0 NOT NULL,
    subscribe_time timestamp without time zone,
    last_posted_file_id integer,
    update_time timestamp without time zone DEFAULT now() NOT NULL,
    last_file_id integer,
    journal_id integer,
    respect_links text,
    comment_list_mode integer DEFAULT 0 NOT NULL,
    draft_category_id integer,
    upload_access integer DEFAULT 0 NOT NULL,
    remove_user_id integer,
    raters integer DEFAULT 0 NOT NULL,
    rating numeric(12,2) DEFAULT 0 NOT NULL,
    event_place character varying(100),
    place_category_id integer,
    event_past boolean DEFAULT false NOT NULL,
    is_sms_sended boolean DEFAULT false NOT NULL,
    sms_sended timestamp without time zone,
    is_sms_weekly_sended boolean DEFAULT false NOT NULL,
    event_id integer,
    event_name character varying(255),
    youtubes integer DEFAULT 0 NOT NULL,
    has_igo boolean DEFAULT false,
    igos_counter integer DEFAULT 0 NOT NULL,
    is_moderated boolean DEFAULT false NOT NULL,
    is_best_sms_sended boolean DEFAULT false NOT NULL,
    is_vote_closed boolean DEFAULT false NOT NULL,
    is_voters_open boolean DEFAULT false NOT NULL,
    videos_looked boolean DEFAULT false NOT NULL,
    escaped_text text,
    topper_id integer,
    CONSTRAINT topic_check CHECK (((movies = 0) OR (dir_id IS NOT NULL))),
    CONSTRAINT topic_check1 CHECK (((music = 0) OR (dir_id IS NOT NULL))),
    CONSTRAINT topic_check2 CHECK (((images = 0) OR (dir_id IS NOT NULL))),
    CONSTRAINT topic_check3 CHECK (((files = 0) OR (dir_id IS NOT NULL))),
    CONSTRAINT topic_youtubes_check CHECK ((youtubes >= 0))
);


ALTER TABLE public.topic OWNER TO nz;

--
-- Name: topic_category; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic_category (
    id integer NOT NULL,
    name character varying(120) NOT NULL,
    description text,
    journal_id integer NOT NULL,
    topics integer DEFAULT 0 NOT NULL,
    last_comment_time timestamp without time zone,
    last_topic_time timestamp without time zone,
    comments bigint DEFAULT 0 NOT NULL,
    changed_time timestamp without time zone,
    CONSTRAINT topic_category_comments_check CHECK ((comments >= 0)),
    CONSTRAINT topic_category_topics_check CHECK ((topics >= 0))
);


ALTER TABLE public.topic_category OWNER TO nz;

--
-- Name: topic_category_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE topic_category_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.topic_category_id_seq OWNER TO nz;

--
-- Name: topic_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE topic_category_id_seq OWNED BY topic_category.id;


--
-- Name: topic_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE topic_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.topic_id_seq OWNER TO nz;

--
-- Name: topic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE topic_id_seq OWNED BY topic.id;


--
-- Name: topic_igos; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic_igos (
    user_id integer NOT NULL,
    topic_id integer NOT NULL
);


ALTER TABLE public.topic_igos OWNER TO nz;

--
-- Name: topic_pippers; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic_pippers (
    user_id integer NOT NULL,
    topic_id integer NOT NULL,
    pips integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.topic_pippers OWNER TO nz;

--
-- Name: topic_to_print; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic_to_print (
    topic_id integer NOT NULL,
    user_id integer NOT NULL,
    result integer
);


ALTER TABLE public.topic_to_print OWNER TO nz;

--
-- Name: topic_views; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic_views (
    topic_id integer NOT NULL,
    user_id integer NOT NULL,
    last_view_comment_id integer,
    last_view_time timestamp without time zone DEFAULT now() NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    is_subscribed boolean DEFAULT false NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    vote_id integer,
    last_posted_comment_id integer,
    new_comments integer DEFAULT 0 NOT NULL,
    new_answers integer DEFAULT 0 NOT NULL,
    answers integer DEFAULT 0 NOT NULL,
    subscribe_time timestamp without time zone,
    last_view_file_id integer,
    new_files integer DEFAULT 0 NOT NULL,
    is_fresh boolean DEFAULT false NOT NULL,
    is_freshed boolean DEFAULT false NOT NULL,
    rating integer,
    vote_time timestamp without time zone,
    CONSTRAINT topic_views_answers_check CHECK ((answers >= 0)),
    CONSTRAINT topic_views_new_answers_check CHECK ((new_answers >= 0)),
    CONSTRAINT topic_views_new_comments_check CHECK ((new_comments >= 0)),
    CONSTRAINT topic_views_new_files_check CHECK ((new_files >= 0)),
    CONSTRAINT topic_views_rating_check CHECK (((rating IS NULL) OR ((rating >= 1) AND (rating <= 5))))
);


ALTER TABLE public.topic_views OWNER TO nz;

--
-- Name: topic_vote; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE topic_vote (
    topic_id integer NOT NULL,
    id integer DEFAULT 0 NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL,
    name character varying(100),
    comment text,
    votes integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.topic_vote OWNER TO nz;

--
-- Name: videos; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE videos (
    id integer NOT NULL,
    link character varying(255) NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    video_type character varying(100) DEFAULT 'youtube'::character varying NOT NULL,
    rutube_id character varying(100),
    video_id character varying(100) NOT NULL,
    topic_id integer NOT NULL,
    comment_id integer,
    image_src character varying(255),
    image_width integer,
    image_height integer,
    title character varying(255),
    local_link character varying(255)
);


ALTER TABLE public.videos OWNER TO nz;

--
-- Name: videos_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE videos_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.videos_id_seq OWNER TO nz;

--
-- Name: videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE videos_id_seq OWNED BY videos.id;


--
-- Name: zabor; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE zabor (
    id integer NOT NULL,
    createtime timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL,
    comment text,
    votes integer DEFAULT 0 NOT NULL,
    image_name character varying(100)
);


ALTER TABLE public.zabor OWNER TO nz;

--
-- Name: zabor_id_seq; Type: SEQUENCE; Schema: public; Owner: nz
--

CREATE SEQUENCE zabor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.zabor_id_seq OWNER TO nz;

--
-- Name: zabor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nz
--

ALTER SEQUENCE zabor_id_seq OWNED BY zabor.id;


--
-- Name: zabor_view; Type: TABLE; Schema: public; Owner: nz; Tablespace: 
--

CREATE TABLE zabor_view (
    user_id integer NOT NULL,
    zabor_id integer NOT NULL,
    max_id integer NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.zabor_view OWNER TO nz;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE auction ALTER COLUMN id SET DEFAULT nextval('auction_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE banner ALTER COLUMN id SET DEFAULT nextval('banner_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE banners_display ALTER COLUMN id SET DEFAULT nextval('banners_display_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE city ALTER COLUMN id SET DEFAULT nextval('city_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE comment ALTER COLUMN id SET DEFAULT nextval('comment_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE filesholder_dir ALTER COLUMN id SET DEFAULT nextval('filesholder_dir_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE filesholder_file ALTER COLUMN id SET DEFAULT nextval('filesholder_file_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE fuser ALTER COLUMN id SET DEFAULT nextval('fuser_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE journal ALTER COLUMN id SET DEFAULT nextval('journal_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE journal_issue ALTER COLUMN id SET DEFAULT nextval('journal_issue_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE mail ALTER COLUMN id SET DEFAULT nextval('mail_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE main_topics ALTER COLUMN id SET DEFAULT nextval('main_topics_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE place ALTER COLUMN id SET DEFAULT nextval('place_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE place2 ALTER COLUMN id SET DEFAULT nextval('place2_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE place_category ALTER COLUMN id SET DEFAULT nextval('place_category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE topic ALTER COLUMN id SET DEFAULT nextval('topic_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE topic_category ALTER COLUMN id SET DEFAULT nextval('topic_category_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE videos ALTER COLUMN id SET DEFAULT nextval('videos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: nz
--

ALTER TABLE zabor ALTER COLUMN id SET DEFAULT nextval('zabor_id_seq'::regclass);


--
-- Name: auction_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY auction
    ADD CONSTRAINT auction_pkey PRIMARY KEY (id);


--
-- Name: city_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);


--
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: file_rating_user_id_key; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY file_rating
    ADD CONSTRAINT file_rating_user_id_key UNIQUE (user_id, file_id);


--
-- Name: filesholder_file_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY filesholder_file
    ADD CONSTRAINT filesholder_file_pkey PRIMARY KEY (id);


--
-- Name: fuser_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY fuser
    ADD CONSTRAINT fuser_pkey PRIMARY KEY (id);


--
-- Name: journal_issue_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY journal_issue
    ADD CONSTRAINT journal_issue_pkey PRIMARY KEY (id);


--
-- Name: journal_members_journal_id_key; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY journal_members
    ADD CONSTRAINT journal_members_journal_id_key UNIQUE (journal_id, user_id);


--
-- Name: journal_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY journal
    ADD CONSTRAINT journal_pkey PRIMARY KEY (id);


--
-- Name: mail_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY mail
    ADD CONSTRAINT mail_pkey PRIMARY KEY (id);


--
-- Name: pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY filesholder_dir
    ADD CONSTRAINT pkey PRIMARY KEY (id);


--
-- Name: place_category_name_key; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY place_category
    ADD CONSTRAINT place_category_name_key UNIQUE (name);


--
-- Name: place_category_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY place_category
    ADD CONSTRAINT place_category_pkey PRIMARY KEY (id);


--
-- Name: place_name_key; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY place
    ADD CONSTRAINT place_name_key UNIQUE (name);


--
-- Name: place_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY place
    ADD CONSTRAINT place_pkey PRIMARY KEY (id);


--
-- Name: topic_category_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY topic_category
    ADD CONSTRAINT topic_category_pkey PRIMARY KEY (id);


--
-- Name: topic_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY topic
    ADD CONSTRAINT topic_pkey PRIMARY KEY (id);


--
-- Name: videos_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (id);


--
-- Name: zabor_pkey; Type: CONSTRAINT; Schema: public; Owner: nz; Tablespace: 
--

ALTER TABLE ONLY zabor
    ADD CONSTRAINT zabor_pkey PRIMARY KEY (id);


--
-- Name: black_user_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX black_user_id ON blacks USING btree (user_id);


--
-- Name: blacks_black_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX blacks_black_id ON blacks USING btree (black_id);


--
-- Name: filesholder_dir_id_key; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX filesholder_dir_id_key ON filesholder_dir USING btree (id);


--
-- Name: filesholder_dir_parent_id_key; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX filesholder_dir_parent_id_key ON filesholder_dir USING btree (parent_id);


--
-- Name: idx_banners_display_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_banners_display_id ON banners_display USING btree (id);


--
-- Name: idx_clickcounter_hpq; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_clickcounter_hpq ON click_counter USING btree (host, path, query);


--
-- Name: idx_dir_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_dir_id ON filesholder_file USING btree (dir_id);


--
-- Name: idx_in_galery; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_in_galery ON filesholder_file USING btree (is_in_gallery);


--
-- Name: idx_jtopic_topicid; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_jtopic_topicid ON journal_topic USING btree (topic_id);


--
-- Name: idx_session; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_session ON fuser USING btree (session);


--
-- Name: idx_topic_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_topic_id ON comment USING btree (topic_id);


--
-- Name: idx_topic_user_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_topic_user_id ON topic USING btree (user_id);


--
-- Name: idx_topic_views_subs_ffreshed; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_topic_views_subs_ffreshed ON topic_views USING btree (is_subscribed, is_freshed);


--
-- Name: idx_topic_views_topic_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX idx_topic_views_topic_id ON topic_views USING btree (topic_id);


--
-- Name: ndx_comment; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_comment ON comment USING btree (topic_id, file_id, id);


--
-- Name: ndx_comment_videos_looked; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_comment_videos_looked ON comment USING btree (videos_looked);


--
-- Name: ndx_filesholder_on_main; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_on_main ON filesholder_file USING btree (is_on_main);


--
-- Name: ndx_filesholder_rating; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_rating ON filesholder_file USING btree (rating, raters);


--
-- Name: ndx_filesholder_topic; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_topic ON filesholder_file USING btree (topic_id, type, thumb_height);


--
-- Name: ndx_filesholder_topic2; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_topic2 ON filesholder_file USING btree (topic_id, type, thumb_width, thumb_height, rating, raters);


--
-- Name: ndx_filesholder_type; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_type ON filesholder_file USING btree (type, "timestamp");


--
-- Name: ndx_filesholder_type_time; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_type_time ON filesholder_file USING btree (type, "timestamp");


--
-- Name: ndx_filesholder_type_user; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_filesholder_type_user ON filesholder_file USING btree (type, user_id);


--
-- Name: ndx_fuser_domain; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_fuser_domain ON fuser USING btree (domain);


--
-- Name: ndx_fuser_logged; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_fuser_logged ON fuser USING btree (lasttime, is_logged);


--
-- Name: ndx_fuser_login; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE UNIQUE INDEX ndx_fuser_login ON fuser USING btree (login);


--
-- Name: ndx_topic; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic ON topic USING btree (journal_id, create_time);


--
-- Name: ndx_topic_event_date; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_event_date ON topic USING btree (event_date);


--
-- Name: ndx_topic_list; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_list ON journal_topic USING btree (journal_id, topic_id, "timestamp");


--
-- Name: ndx_topic_on_mail; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_on_mail ON journal_topic USING btree (is_on_main, journal_id, "timestamp");


--
-- Name: ndx_topic_sticky; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_sticky ON journal_topic USING btree (journal_id, sticky_date);


--
-- Name: ndx_topic_topic_type; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_topic_type ON topic USING btree (topic_type, event_date);


--
-- Name: ndx_topic_videos_looked; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_videos_looked ON topic USING btree (videos_looked);


--
-- Name: ndx_topic_views_new_answers; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_topic_views_new_answers ON topic_views USING btree (user_id, ((new_answers > 0)));


--
-- Name: ndx_topic_vote_id; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE UNIQUE INDEX ndx_topic_vote_id ON topic_vote USING btree (topic_id, id);


--
-- Name: ndx_videos_comment; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE UNIQUE INDEX ndx_videos_comment ON videos USING btree (comment_id, link);


--
-- Name: ndx_videos_time; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX ndx_videos_time ON videos USING btree ("timestamp");


--
-- Name: ndx_videos_unique; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE UNIQUE INDEX ndx_videos_unique ON videos USING btree (topic_id, link);


--
-- Name: new_mails_idx; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX new_mails_idx ON mail USING btree (user_id, is_inbox, is_shown);


--
-- Name: topic_to_print_idx; Type: INDEX; Schema: public; Owner: nz; Tablespace: 
--

CREATE INDEX topic_to_print_idx ON topic_to_print USING btree (topic_id);


--
-- Name: file_rating_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY file_rating
    ADD CONSTRAINT file_rating_file_id_fkey FOREIGN KEY (file_id) REFERENCES filesholder_file(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: file_rating_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY file_rating
    ADD CONSTRAINT file_rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES fuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: journal_members_journal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY journal_members
    ADD CONSTRAINT journal_members_journal_id_fkey FOREIGN KEY (journal_id) REFERENCES journal(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: journal_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY journal_members
    ADD CONSTRAINT journal_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES fuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: place_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY place
    ADD CONSTRAINT place_city_id_fkey FOREIGN KEY (city_id) REFERENCES city(id) ON DELETE SET NULL;


--
-- Name: place_place_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY place
    ADD CONSTRAINT place_place_category_id_fkey FOREIGN KEY (place_category_id) REFERENCES place_category(id) ON DELETE SET NULL;


--
-- Name: topic_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY topic
    ADD CONSTRAINT topic_event_id_fkey FOREIGN KEY (event_id) REFERENCES topic(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: topic_igos_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY topic_igos
    ADD CONSTRAINT topic_igos_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topic_igos_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY topic_igos
    ADD CONSTRAINT topic_igos_user_id_fkey FOREIGN KEY (user_id) REFERENCES fuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topic_vote_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nz
--

ALTER TABLE ONLY topic_vote
    ADD CONSTRAINT topic_vote_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

