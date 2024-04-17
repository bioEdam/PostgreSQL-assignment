DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE ownership AS ENUM
    ('our', 'loaned');

CREATE TYPE states AS ENUM
    ('in_storage', 'in_exhibition', 'in_transit', 'in_restoration', 'in_f_institute');

CREATE TYPE institute_types AS ENUM
    ('museum', 'gallery', 'library', 'archive', 'private_collection', 'other');

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artefacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    ownership ownership NOT NULL DEFAULT 'our',
    state states NOT NULL,
    zone_id UUID,  -- zone where the artefact is currently located
    exhibition_id UUID,   -- exhibition which is currently part of
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artefact_category (
    artefact_id UUID REFERENCES artefacts(id),
    category_id UUID REFERENCES categories(id),
    PRIMARY KEY (artefact_id, category_id)
);

CREATE TABLE zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exhibitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- artefacts - exhibitions M:N
CREATE TABLE artefact_exhibition (
    artefact_id UUID REFERENCES artefacts(id),
    exhibition_id UUID REFERENCES exhibitions(id),
    PRIMARY KEY (artefact_id, exhibition_id)
);

-- zones - exhibitions M:N
CREATE TABLE exhibition_zone (
    zone_id UUID REFERENCES zones(id),
    exhibition_id UUID REFERENCES exhibitions(id),
    PRIMARY KEY (zone_id, exhibition_id)
);

CREATE TABLE institutes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL,
    town VARCHAR(255) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    institute_type institute_types NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE loans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artefact_id UUID REFERENCES artefacts(id) NOT NULL,
    loaned_from UUID REFERENCES institutes(id),
    loaned_to UUID REFERENCES institutes(id),
    expected_arrival_date TIMESTAMP WITH TIME ZONE,
    arrival_date TIMESTAMP WITH TIME ZONE,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- checks for artefacts (specialy for artefacts that are loaned to someone)
CREATE TABLE checks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loan_id UUID REFERENCES loans(id),  -- now nullable so that we can create checks for artefacts that are not loned
    artefact_id UUID REFERENCES artefacts(id) NOT NULL,
    results TEXT,
    duration INTERVAL,
    check_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- after every change in the artefacts table, a new row will be inserted
CREATE TABLE artefacts_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artefact_id UUID REFERENCES artefacts(id) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    ownership ownership NOT NULL DEFAULT 'our',
    state states NOT NULL,
    zone_id UUID,  -- zone where the artefact is currently located
    exhibition_id UUID,   -- exhibition which is currently part of
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);