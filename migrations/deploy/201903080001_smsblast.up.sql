DO $$ BEGIN
  CREATE EXTENSION pgcrypto;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE TABLE notification_smsblast (
    id UUID NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),

    sender VARCHAR(200) NOT NULL,
    msisdn VARCHAR(30) NOT NULL,
    message TEXT NOT NULL,
    campaign_name VARCHAR(200) NULL,
    receipt_id VARCHAR(200) NULL,
    status INTEGER NOT NULL,

    delivery_status INT NULL,
    delivery_text TEXT NULL,

    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP NULL    
);