CREATE TABLE public.account_details (
    id bigint NOT NULL,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_first_name character varying NOT NULL,
    encrypted_first_name_iv character varying,
    encrypted_last_name character varying NOT NULL,
    encrypted_last_name_iv character varying,
    encrypted_address_1 character varying NOT NULL,
    encrypted_address_1_iv character varying,
    encrypted_address_2 character varying,
    encrypted_address_2_iv character varying,
    encrypted_city character varying NOT NULL,
    encrypted_city_iv character varying,
    encrypted_postal character varying NOT NULL,
    encrypted_postal_iv character varying,
    encrypted_province character varying NOT NULL,
    encrypted_province_iv character varying,
    status integer DEFAULT 0,
    encrypted_dob character varying,
    encrypted_dob_iv character varying
);

CREATE TABLE public.admins (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    otp_secret_key character varying,
    otp_module integer DEFAULT 0,
    temp_token character varying,
    temp_token_expiry timestamp without time zone,
    otp_backup_codes character varying[]
);

CREATE TABLE public.ahoy_events (
    id bigint NOT NULL,
    visit_id bigint,
    user_id bigint,
    name character varying,
    properties jsonb,
    "time" timestamp without time zone
);

CREATE TABLE public.ahoy_visits (
    id bigint NOT NULL,
    visit_token character varying,
    visitor_token character varying,
    user_id bigint,
    ip character varying,
    user_agent text,
    referrer text,
    referring_domain character varying,
    search_keyword character varying,
    landing_page text,
    browser character varying,
    os character varying,
    device_type character varying,
    country character varying,
    region character varying,
    city character varying,
    utm_source character varying,
    utm_medium character varying,
    utm_term character varying,
    utm_content character varying,
    utm_campaign character varying,
    started_at timestamp without time zone
);

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.currencies (
    id bigint NOT NULL,
    name character varying,
    unit character varying,
    separator character varying DEFAULT '.'::character varying,
    delimiter character varying DEFAULT ''::character varying,
    format character varying DEFAULT '%u %n'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    fiat boolean,
    "precision" integer
);

CREATE TABLE public.id_verifications (
    id bigint NOT NULL,
    user_id integer,
    label integer,
    status integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.image_attachments (
    id bigint NOT NULL,
    image character varying,
    label integer,
    id_verification_id integer
);

CREATE TABLE public.orders (
    id bigint NOT NULL,
    amount bigint NOT NULL,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0,
    type character varying,
    from_currency_id integer,
    to_currency_id integer,
    funding_type integer,
    rate double precision,
    processed_at bigint,
    token character varying,
    tx_hash character varying,
    block_hash character varying,
    block_time timestamp without time zone,
    withdrawal_wallet_address character varying,
    eft_transfer_password character varying,
    withdrawal_type integer,
    guid character varying,
    sent_at bigint,
    buy_when_funding boolean DEFAULT false,
    wallet_id integer,
    amount_received integer,
    amount_fiat bigint,
    promo_code_id uuid,
    promo_code_percentage integer,
    visit_id bigint
);


CREATE TABLE public.phone_verifications (
    id bigint NOT NULL,
    user_id integer,
    label character varying,
    status integer DEFAULT 0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    code character varying,
    encrypted_number character varying,
    encrypted_number_iv character varying
);

CREATE TABLE public.promo_codes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    admin_id integer NOT NULL,
    code text NOT NULL,
    description text NOT NULL,
    discount_percentage integer NOT NULL,
    active_from timestamp without time zone NOT NULL,
    active_until timestamp without time zone,
    max_per_code integer,
    max_per_user integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.rates (
    id bigint NOT NULL,
    rate_type integer,
    percent integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    otp_secret_key character varying,
    otp_module integer DEFAULT 0,
    temp_token character varying,
    temp_token_expiry timestamp without time zone,
    otp_backup_codes character varying[],
    activation_notification_sent boolean DEFAULT false,
    agreed_to_terms boolean,
    blocked boolean DEFAULT false,
    referred_by integer,
    referral_token character varying
);

CREATE TABLE public.wallets (
    id bigint NOT NULL,
    user_id integer,
    label integer,
    address character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    used boolean DEFAULT false
);
