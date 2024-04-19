DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- enum for loans
CREATE TYPE loan_directions AS ENUM
    ('loan_in', 'loan_out');

-- enums for artefacts
CREATE TYPE ownership AS ENUM
    ('our', 'loaned');

CREATE TYPE states AS ENUM
    ('in_storage', 'in_exhibition', 'in_transit', 'in_restoration', 'in_loan');

-- enum for institutes
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

-- add refences to zone_id and exhibition_id in the artefacts table
ALTER TABLE artefacts
ADD FOREIGN KEY (zone_id) REFERENCES zones(id),
ADD FOREIGN KEY (exhibition_id) REFERENCES exhibitions(id);

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
    artefact_id UUID,
    institute_id UUID,
    loan_type loan_directions NOT NULL,
    expected_arrival_date TIMESTAMP WITH TIME ZONE,
    arrival_date TIMESTAMP WITH TIME ZONE,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (artefact_id) REFERENCES artefacts(id) ON DELETE CASCADE,
    FOREIGN KEY (institute_id) REFERENCES institutes(id)
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
    zone_id UUID REFERENCES zones(id),  -- zone where the artefact is currently located
    exhibition_id UUID REFERENCES exhibitions(id),   -- exhibition which is currently part of
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);