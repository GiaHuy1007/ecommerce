CREATE TABLE shedlock
(
    name       VARCHAR(64)  NOT NULL,
    lock_until TIMESTAMPTZ  NOT NULL,
    locked_at  TIMESTAMPTZ  NOT NULL,
    locked_by  VARCHAR(255) NOT NULL,
    PRIMARY KEY (name)
);

-- 1. ROLES
CREATE TABLE roles
(
    id          BIGSERIAL PRIMARY KEY,
    code        VARCHAR(30)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_roles_code UNIQUE (code),
    CONSTRAINT chk_roles_code CHECK (code IN ('CUSTOMER', 'STAFF', 'ADMIN'))
);

-- 2. USERS
CREATE TABLE users
(
    id             BIGSERIAL PRIMARY KEY,
    role_id        BIGINT       NOT NULL,
    email          VARCHAR(150) NOT NULL,
    phone          VARCHAR(20),
    password_hash  VARCHAR(255) NOT NULL,
    full_name      VARCHAR(120) NOT NULL,
    avatar_url     VARCHAR(500),
    gender         VARCHAR(15),
    date_of_birth  DATE,
    status         VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    email_verified BOOLEAN      NOT NULL DEFAULT FALSE,
    last_login_at  TIMESTAMPTZ,
    is_deleted     BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_at     TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by     BIGINT,
    updated_by     BIGINT,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles (id) ON DELETE RESTRICT,
    CONSTRAINT chk_users_gender CHECK (gender IS NULL OR gender IN ('MALE', 'FEMALE', 'OTHER')),
    CONSTRAINT chk_users_status CHECK (status IN ('PENDING', 'ACTIVE', 'LOCKED'))
);

CREATE UNIQUE INDEX uk_users_email ON users (LOWER(email)) WHERE is_deleted = FALSE;
CREATE UNIQUE INDEX uk_users_phone ON users (phone) WHERE phone IS NOT NULL AND is_deleted = FALSE;
CREATE INDEX idx_users_role_status ON users (role_id, status) WHERE is_deleted = FALSE;

-- 3. USER_TOKENS
CREATE TABLE user_tokens
(
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT       NOT NULL,
    token_hash VARCHAR(128) NOT NULL,
    token_type VARCHAR(30)  NOT NULL,
    expires_at TIMESTAMPTZ  NOT NULL,
    used_at    TIMESTAMPTZ,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_user_tokens_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT uk_user_tokens_hash UNIQUE (token_hash),
    CONSTRAINT chk_user_tokens_type CHECK (token_type IN ('EMAIL_VERIFICATION', 'PASSWORD_RESET'))
);

CREATE INDEX idx_user_tokens_user_type ON user_tokens (user_id, token_type);

-- 4. USER_ADDRESSES
CREATE TABLE user_addresses
(
    id             BIGSERIAL PRIMARY KEY,
    user_id        BIGINT       NOT NULL,
    receiver_name  VARCHAR(120) NOT NULL,
    receiver_phone VARCHAR(20)  NOT NULL,
    province_code  VARCHAR(20)  NOT NULL,
    province_name  VARCHAR(100) NOT NULL,
    district_code  VARCHAR(20)  NOT NULL,
    district_name  VARCHAR(100) NOT NULL,
    ward_code      VARCHAR(20)  NOT NULL,
    ward_name      VARCHAR(100) NOT NULL,
    address_detail VARCHAR(255) NOT NULL,
    address_type   VARCHAR(20)  NOT NULL DEFAULT 'HOME',
    is_default     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_user_addresses_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT chk_user_addresses_type CHECK (address_type IN ('HOME', 'OFFICE', 'OTHER'))
);

CREATE INDEX idx_user_addresses_user ON user_addresses (user_id, is_default DESC);
CREATE UNIQUE INDEX uk_user_addresses_default ON user_addresses (user_id) WHERE is_default = TRUE;

-- 5. CATEGORIES
CREATE TABLE categories
(
    id            BIGSERIAL PRIMARY KEY,
    parent_id     BIGINT,
    name          VARCHAR(120) NOT NULL,
    slug          VARCHAR(150) NOT NULL,
    description   TEXT,
    image_url     VARCHAR(500),
    level         SMALLINT     NOT NULL DEFAULT 1,
    path          VARCHAR(255),
    display_order INT          NOT NULL DEFAULT 0,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    is_deleted    BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_at    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by    BIGINT,
    updated_by    BIGINT,
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE RESTRICT,
    CONSTRAINT chk_categories_level CHECK (level >= 1 AND level <= 5)
);

CREATE UNIQUE INDEX uk_categories_slug ON categories (slug) WHERE is_deleted = FALSE;
CREATE INDEX idx_categories_parent ON categories (parent_id, display_order) WHERE is_deleted = FALSE;
CREATE INDEX idx_categories_path ON categories (path varchar_pattern_ops) WHERE is_deleted = FALSE;

-- 6. BRANDS
CREATE TABLE brands
(
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(120) NOT NULL,
    slug        VARCHAR(150) NOT NULL,
    logo_url    VARCHAR(500),
    description TEXT,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    is_deleted  BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    created_by  BIGINT,
    updated_by  BIGINT
);

CREATE UNIQUE INDEX uk_brands_slug ON brands (slug) WHERE is_deleted = FALSE;

-- 7. SIZES
CREATE TABLE sizes
(
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(30) NOT NULL,
    name          VARCHAR(50) NOT NULL,
    size_group    VARCHAR(30) NOT NULL DEFAULT 'TOP',
    display_order INT         NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_sizes_code UNIQUE (code),
    CONSTRAINT chk_sizes_group CHECK (size_group IN ('TOP', 'BOTTOM', 'SHOES', 'ACCESSORY'))
);

-- 8. COLORS
CREATE TABLE colors
(
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(30) NOT NULL,
    name          VARCHAR(50) NOT NULL,
    hex_code      VARCHAR(7)  NOT NULL,
    display_order INT         NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_colors_code UNIQUE (code),
    CONSTRAINT chk_colors_hex CHECK (hex_code ~ '^#[0-9A-Fa-f]{6}$')
);

-- 9. TAGS
CREATE TABLE tags
(
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(80)  NOT NULL,
    slug       VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_tags_slug UNIQUE (slug)
);

-- 10. PRODUCTS
CREATE TABLE products
(
    id                BIGSERIAL PRIMARY KEY,
    category_id       BIGINT         NOT NULL,
    brand_id          BIGINT,
    name              VARCHAR(255)   NOT NULL,
    slug              VARCHAR(280)   NOT NULL,
    sku_prefix        VARCHAR(50)    NOT NULL,
    short_description VARCHAR(500),
    description       TEXT,
    material          VARCHAR(150),
    thumbnail_url     VARCHAR(500)   NOT NULL,
    base_price        NUMERIC(15, 2) NOT NULL,
    min_price         NUMERIC(15, 2) NOT NULL,
    max_price         NUMERIC(15, 2) NOT NULL,
    total_sold        INT            NOT NULL DEFAULT 0,
    rating_avg        NUMERIC(3, 2)  NOT NULL DEFAULT 0.00,
    review_count      INT            NOT NULL DEFAULT 0,
    status            VARCHAR(20)    NOT NULL DEFAULT 'DRAFT',
    meta_title        VARCHAR(255),
    meta_description  VARCHAR(500),
    is_deleted        BOOLEAN        NOT NULL DEFAULT FALSE,
    deleted_at        TIMESTAMPTZ,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    created_by        BIGINT,
    updated_by        BIGINT,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE RESTRICT,
    CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES brands (id) ON DELETE SET NULL,
    CONSTRAINT chk_products_prices CHECK (base_price >= 0 AND min_price >= 0 AND max_price >= min_price),
    CONSTRAINT chk_products_stats CHECK (total_sold >= 0 AND review_count >= 0 AND rating_avg BETWEEN 0 AND 5),
    CONSTRAINT chk_products_status CHECK (status IN ('DRAFT', 'ACTIVE', 'INACTIVE'))
);

CREATE UNIQUE INDEX uk_products_slug ON products (slug) WHERE is_deleted = FALSE;
CREATE INDEX idx_products_cat_status_created ON products (category_id, status, created_at DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_products_status_price ON products (status, min_price, max_price) WHERE is_deleted = FALSE;
CREATE INDEX idx_products_status_sold ON products (status, total_sold DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_products_brand ON products (brand_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_products_search_name ON products USING gin (to_tsvector('simple', name)) WHERE is_deleted = FALSE;

-- 11. PRODUCT_TAGS
CREATE TABLE product_tags
(
    product_id BIGINT NOT NULL,
    tag_id     BIGINT NOT NULL,
    PRIMARY KEY (product_id, tag_id),
    CONSTRAINT fk_product_tags_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    CONSTRAINT fk_product_tags_tag FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
);

CREATE INDEX idx_product_tags_tag ON product_tags (tag_id);

-- 12. PRODUCT_IMAGES
CREATE TABLE product_images
(
    id            BIGSERIAL PRIMARY KEY,
    product_id    BIGINT       NOT NULL,
    color_id      BIGINT,
    image_url     VARCHAR(500) NOT NULL,
    alt_text      VARCHAR(255),
    is_primary    BOOLEAN      NOT NULL DEFAULT FALSE,
    display_order INT          NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    CONSTRAINT fk_product_images_color FOREIGN KEY (color_id) REFERENCES colors (id) ON DELETE SET NULL
);

CREATE INDEX idx_product_images_product ON product_images (product_id, display_order);

-- 13. PRODUCT_VARIANTS
CREATE TABLE product_variants
(
    id           BIGSERIAL PRIMARY KEY,
    product_id   BIGINT         NOT NULL,
    size_id      BIGINT         NOT NULL,
    color_id     BIGINT         NOT NULL,
    sku          VARCHAR(80)    NOT NULL,
    price        NUMERIC(15, 2) NOT NULL,
    sale_price   NUMERIC(15, 2),
    weight_grams INT            NOT NULL DEFAULT 300,
    image_url    VARCHAR(500),
    is_active    BOOLEAN        NOT NULL DEFAULT TRUE,
    is_deleted   BOOLEAN        NOT NULL DEFAULT FALSE,
    deleted_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    created_by   BIGINT,
    updated_by   BIGINT,
    CONSTRAINT fk_variants_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT,
    CONSTRAINT fk_variants_size FOREIGN KEY (size_id) REFERENCES sizes (id) ON DELETE RESTRICT,
    CONSTRAINT fk_variants_color FOREIGN KEY (color_id) REFERENCES colors (id) ON DELETE RESTRICT,
    CONSTRAINT chk_variants_price CHECK (price >= 0 AND
                                         (sale_price IS NULL OR (sale_price >= 0 AND sale_price < price))),
    CONSTRAINT chk_variants_weight CHECK (weight_grams > 0)
);

CREATE UNIQUE INDEX uk_variants_sku ON product_variants (sku) WHERE is_deleted = FALSE;
CREATE UNIQUE INDEX uk_variants_prod_size_color ON product_variants (product_id, size_id, color_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_variants_size_color ON product_variants (size_id, color_id, product_id) WHERE is_deleted = FALSE AND is_active = TRUE;

-- 14. INVENTORIES
CREATE TABLE inventories
(
    id                  BIGSERIAL PRIMARY KEY,
    variant_id          BIGINT      NOT NULL,
    quantity_on_hand    INT         NOT NULL DEFAULT 0,
    quantity_reserved   INT         NOT NULL DEFAULT 0,
    low_stock_threshold INT         NOT NULL DEFAULT 5,
    version             BIGINT      NOT NULL DEFAULT 0,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_inventories_variant UNIQUE (variant_id),
    CONSTRAINT fk_inventories_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,
    CONSTRAINT chk_inventories_qty CHECK (quantity_on_hand >= 0 AND quantity_reserved >= 0 AND
                                          quantity_reserved <= quantity_on_hand),
    CONSTRAINT chk_inventories_threshold CHECK (low_stock_threshold >= 0)
);

CREATE INDEX idx_inventories_low_stock ON inventories ((quantity_on_hand - quantity_reserved))
    WHERE (quantity_on_hand - quantity_reserved) <= low_stock_threshold;

-- 15. INVENTORY_NOTES
CREATE TABLE inventory_notes
(
    id             BIGSERIAL PRIMARY KEY,
    note_code      VARCHAR(40)    NOT NULL,
    note_type      VARCHAR(20)    NOT NULL,
    supplier_name  VARCHAR(150),
    reference_code VARCHAR(100),
    total_items    INT            NOT NULL DEFAULT 0,
    total_cost     NUMERIC(15, 2) NOT NULL DEFAULT 0,
    note           TEXT,
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    created_by     BIGINT,
    updated_by     BIGINT,
    CONSTRAINT uk_inventory_notes_code UNIQUE (note_code),
    CONSTRAINT fk_inventory_notes_creator FOREIGN KEY (created_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_inventory_notes_type CHECK (note_type IN ('IMPORT', 'EXPORT', 'ADJUSTMENT'))
);

CREATE INDEX idx_inventory_notes_type_created ON inventory_notes (note_type, created_at DESC);

-- 16. INVENTORY_NOTE_ITEMS
CREATE TABLE inventory_note_items
(
    id         BIGSERIAL PRIMARY KEY,
    note_id    BIGINT         NOT NULL,
    variant_id BIGINT         NOT NULL,
    quantity   INT            NOT NULL,
    unit_cost  NUMERIC(15, 2) NOT NULL DEFAULT 0,
    note       VARCHAR(255),
    CONSTRAINT fk_inv_note_items_note FOREIGN KEY (note_id) REFERENCES inventory_notes (id) ON DELETE CASCADE,
    CONSTRAINT fk_inv_note_items_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,
    CONSTRAINT uk_inv_note_items_note_variant UNIQUE (note_id, variant_id),
    CONSTRAINT chk_inv_note_items_qty CHECK (quantity != 0 AND unit_cost >= 0)
);

-- 17. INVENTORY_TRANSACTIONS
CREATE TABLE inventory_transactions
(
    id               BIGSERIAL PRIMARY KEY,
    variant_id       BIGINT      NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    quantity_change  INT         NOT NULL,
    quantity_before  INT         NOT NULL,
    quantity_after   INT         NOT NULL,
    reserved_before  INT         NOT NULL,
    reserved_after   INT         NOT NULL,
    reference_type   VARCHAR(30) NOT NULL,
    reference_id     BIGINT      NOT NULL,
    reference_code   VARCHAR(50) NOT NULL,
    note             VARCHAR(255),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by       BIGINT,
    CONSTRAINT fk_inv_tx_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,
    CONSTRAINT chk_inv_tx_type CHECK (transaction_type IN (
                                                           'IMPORT', 'EXPORT', 'ADJUSTMENT', 'ORDER_RESERVE',
                                                           'ORDER_RELEASE', 'ORDER_DEDUCT', 'ORDER_RETURN'
        )),
    CONSTRAINT chk_inv_tx_ref_type CHECK (reference_type IN ('INVENTORY_NOTE', 'ORDER', 'ORDER_RETURN'))
);

CREATE INDEX idx_inv_tx_variant_created ON inventory_transactions (variant_id, created_at DESC);

-- 18. CARTS
CREATE TABLE carts
(
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT      NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_carts_user UNIQUE (user_id),
    CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- 19. CART_ITEMS
CREATE TABLE cart_items
(
    id         BIGSERIAL PRIMARY KEY,
    cart_id    BIGINT      NOT NULL,
    variant_id BIGINT      NOT NULL,
    quantity   INT         NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) REFERENCES carts (id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE CASCADE,
    CONSTRAINT uk_cart_items_cart_variant UNIQUE (cart_id, variant_id),
    CONSTRAINT chk_cart_items_qty CHECK (quantity >= 1 AND quantity <= 50)
);

-- 20. VOUCHERS
CREATE TABLE vouchers
(
    id                   BIGSERIAL PRIMARY KEY,
    code                 VARCHAR(40)    NOT NULL,
    name                 VARCHAR(150)   NOT NULL,
    description          VARCHAR(500),
    discount_type        VARCHAR(20)    NOT NULL,
    discount_value       NUMERIC(15, 2) NOT NULL,
    min_order_amount     NUMERIC(15, 2) NOT NULL DEFAULT 0,
    max_discount_amount  NUMERIC(15, 2),
    scope_type           VARCHAR(20)    NOT NULL DEFAULT 'ALL',
    usage_limit          INT            NOT NULL,
    used_count           INT            NOT NULL DEFAULT 0,
    usage_limit_per_user INT            NOT NULL DEFAULT 1,
    start_at             TIMESTAMPTZ    NOT NULL,
    end_at               TIMESTAMPTZ    NOT NULL,
    is_active            BOOLEAN        NOT NULL DEFAULT TRUE,
    version              BIGINT         NOT NULL DEFAULT 0,
    is_deleted           BOOLEAN        NOT NULL DEFAULT FALSE,
    deleted_at           TIMESTAMPTZ,
    created_at           TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    created_by           BIGINT,
    updated_by           BIGINT,
    CONSTRAINT chk_vouchers_discount_type CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT')),
    CONSTRAINT chk_vouchers_discount_val CHECK (
        discount_value > 0 AND (discount_type != 'PERCENTAGE' OR discount_value <= 100)
        ),
    CONSTRAINT chk_vouchers_amounts CHECK (
        min_order_amount >= 0 AND (max_discount_amount IS NULL OR max_discount_amount > 0)
        ),
    CONSTRAINT chk_vouchers_scope CHECK (scope_type IN ('ALL', 'CATEGORY', 'PRODUCT')),
    CONSTRAINT chk_vouchers_usage CHECK (
        usage_limit > 0 AND used_count >= 0 AND used_count <= usage_limit AND usage_limit_per_user > 0
        ),
    CONSTRAINT chk_vouchers_dates CHECK (end_at > start_at)
);

CREATE UNIQUE INDEX uk_vouchers_code ON vouchers (UPPER(code)) WHERE is_deleted = FALSE;
CREATE INDEX idx_vouchers_active_time ON vouchers (is_active, start_at, end_at) WHERE is_deleted = FALSE;

-- 21. VOUCHER_CATEGORIES
CREATE TABLE voucher_categories
(
    voucher_id  BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    PRIMARY KEY (voucher_id, category_id),
    CONSTRAINT fk_voucher_cats_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers (id) ON DELETE CASCADE,
    CONSTRAINT fk_voucher_cats_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
);

-- 22. VOUCHER_PRODUCTS
CREATE TABLE voucher_products
(
    voucher_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    PRIMARY KEY (voucher_id, product_id),
    CONSTRAINT fk_voucher_prods_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers (id) ON DELETE CASCADE,
    CONSTRAINT fk_voucher_prods_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);

-- 24. SHIPPING_ZONES
CREATE TABLE shipping_zones
(
    id                      BIGSERIAL PRIMARY KEY,
    code                    VARCHAR(30)    NOT NULL,
    name                    VARCHAR(120)   NOT NULL,
    province_codes          JSONB          NOT NULL DEFAULT '[]'::jsonb,
    base_fee                NUMERIC(15, 2) NOT NULL,
    free_shipping_threshold NUMERIC(15, 2),
    estimated_days_min      SMALLINT       NOT NULL DEFAULT 2,
    estimated_days_max      SMALLINT       NOT NULL DEFAULT 4,
    is_active               BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_shipping_zones_code UNIQUE (code),
    CONSTRAINT chk_shipping_zones_fee CHECK (base_fee >= 0 AND
                                             (free_shipping_threshold IS NULL OR free_shipping_threshold >= 0))
);

CREATE INDEX idx_shipping_zones_provinces ON shipping_zones USING gin (province_codes);

-- 25. ORDERS
CREATE TABLE orders
(
    id                      BIGSERIAL PRIMARY KEY,
    order_code              VARCHAR(30)    NOT NULL,
    idempotency_key         VARCHAR(64)    NOT NULL,
    user_id                 BIGINT         NOT NULL,
    status                  VARCHAR(25)    NOT NULL DEFAULT 'PENDING',
    payment_method          VARCHAR(20)    NOT NULL,
    payment_status          VARCHAR(20)    NOT NULL DEFAULT 'UNPAID',
    payment_expires_at      TIMESTAMPTZ,
    receiver_name           VARCHAR(120)   NOT NULL,
    receiver_phone          VARCHAR(20)    NOT NULL,
    shipping_province       VARCHAR(100)   NOT NULL,
    shipping_district       VARCHAR(100)   NOT NULL,
    shipping_ward           VARCHAR(100)   NOT NULL,
    shipping_address_detail VARCHAR(255)   NOT NULL,
    subtotal_amount         NUMERIC(15, 2) NOT NULL,
    discount_amount         NUMERIC(15, 2) NOT NULL DEFAULT 0,
    shipping_fee            NUMERIC(15, 2) NOT NULL DEFAULT 0,
    total_amount            NUMERIC(15, 2) NOT NULL,
    voucher_id              BIGINT,
    voucher_code            VARCHAR(40),
    shipping_zone_id        BIGINT,
    shipping_provider       VARCHAR(30)             DEFAULT 'INTERNAL',
    tracking_number         VARCHAR(60),
    note                    VARCHAR(500),
    cancel_reason           VARCHAR(500),
    confirmed_at            TIMESTAMPTZ,
    shipping_at             TIMESTAMPTZ,
    delivered_at            TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    cancelled_at            TIMESTAMPTZ,
    version                 BIGINT         NOT NULL DEFAULT 0,
    created_at              TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    created_by              BIGINT,
    updated_by              BIGINT,
    CONSTRAINT uk_orders_code UNIQUE (order_code),
    CONSTRAINT uk_orders_idempotency UNIQUE (idempotency_key),
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers (id) ON DELETE SET NULL,
    CONSTRAINT fk_orders_shipping_zone FOREIGN KEY (shipping_zone_id) REFERENCES shipping_zones (id) ON DELETE SET NULL,
    CONSTRAINT chk_orders_status CHECK (status IN (
                                                   'PENDING', 'CONFIRMED', 'SHIPPING', 'DELIVERED', 'COMPLETED',
                                                   'CANCELLED', 'RETURN_REQUESTED', 'RETURNED', 'REFUNDED'
        )),
    CONSTRAINT chk_orders_payment_method CHECK (payment_method IN ('COD', 'VNPAY')),
    CONSTRAINT chk_orders_payment_status CHECK (payment_status IN ('UNPAID', 'PAID', 'FAILED', 'REFUNDED')),
    CONSTRAINT chk_orders_amounts CHECK (
        subtotal_amount >= 0 AND discount_amount >= 0 AND shipping_fee >= 0 AND total_amount >= 0
        )
);

CREATE INDEX idx_orders_user_status_created ON orders (user_id, status, created_at DESC);
CREATE INDEX idx_orders_expired_vnpay ON orders (payment_expires_at)
    WHERE status = 'PENDING' AND payment_method = 'VNPAY' AND payment_status = 'UNPAID';
CREATE INDEX idx_orders_completed_at ON orders (completed_at) WHERE status = 'COMPLETED';

-- 23. VOUCHER_USAGES
CREATE TABLE voucher_usages
(
    id              BIGSERIAL PRIMARY KEY,
    voucher_id      BIGINT         NOT NULL,
    user_id         BIGINT         NOT NULL,
    order_id        BIGINT         NOT NULL,
    discount_amount NUMERIC(15, 2) NOT NULL,
    is_reverted     BOOLEAN        NOT NULL DEFAULT FALSE,
    used_at         TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_voucher_usages_order UNIQUE (order_id),
    CONSTRAINT fk_voucher_usages_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers (id) ON DELETE RESTRICT,
    CONSTRAINT fk_voucher_usages_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_voucher_usages_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT
);

CREATE INDEX idx_voucher_usages_voucher_user ON voucher_usages (voucher_id, user_id) WHERE is_reverted = FALSE;

-- 26. ORDER_ITEMS
CREATE TABLE order_items
(
    id                     BIGSERIAL PRIMARY KEY,
    order_id               BIGINT         NOT NULL,
    product_id             BIGINT         NOT NULL,
    variant_id             BIGINT         NOT NULL,
    product_name_snapshot  VARCHAR(255)   NOT NULL,
    sku_snapshot           VARCHAR(80)    NOT NULL,
    size_name_snapshot     VARCHAR(50)    NOT NULL,
    color_name_snapshot    VARCHAR(50)    NOT NULL,
    variant_image_snapshot VARCHAR(500),
    original_price         NUMERIC(15, 2) NOT NULL,
    unit_price             NUMERIC(15, 2) NOT NULL,
    quantity               INT            NOT NULL,
    line_total             NUMERIC(15, 2) NOT NULL,
    is_reviewed            BOOLEAN        NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_items_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,
    CONSTRAINT chk_order_items_qty_price CHECK (quantity > 0 AND original_price >= 0 AND unit_price >= 0 AND line_total >= 0)
);

CREATE INDEX idx_order_items_order ON order_items (order_id);
CREATE INDEX idx_order_items_product ON order_items (product_id);

-- 27. ORDER_STATUS_HISTORIES
CREATE TABLE order_status_histories
(
    id          BIGSERIAL PRIMARY KEY,
    order_id    BIGINT      NOT NULL,
    from_status VARCHAR(25),
    to_status   VARCHAR(25) NOT NULL,
    note        VARCHAR(500),
    changed_by  BIGINT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_order_histories_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_order_histories_user FOREIGN KEY (changed_by) REFERENCES users (id) ON DELETE SET NULL
);

CREATE INDEX idx_order_histories_order ON order_status_histories (order_id, created_at ASC);

-- 28. ORDER_RETURNS
CREATE TABLE order_returns
(
    id                BIGSERIAL PRIMARY KEY,
    order_id          BIGINT         NOT NULL,
    user_id           BIGINT         NOT NULL,
    return_code       VARCHAR(30)    NOT NULL,
    status            VARCHAR(25)    NOT NULL DEFAULT 'RETURN_REQUESTED',
    reason            TEXT           NOT NULL,
    images_json       JSONB          NOT NULL DEFAULT '[]'::jsonb,
    refund_amount     NUMERIC(15, 2) NOT NULL DEFAULT 0,
    bank_name         VARCHAR(100),
    bank_account_no   VARCHAR(50),
    bank_account_name VARCHAR(120),
    admin_note        TEXT,
    processed_by      BIGINT,
    processed_at      TIMESTAMPTZ,
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_order_returns_order UNIQUE (order_id),
    CONSTRAINT uk_order_returns_code UNIQUE (return_code),
    CONSTRAINT fk_order_returns_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_returns_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_returns_processor FOREIGN KEY (processed_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_order_returns_status CHECK (status IN (
                                                          'RETURN_REQUESTED', 'APPROVED', 'REJECTED', 'RETURNED',
                                                          'REFUNDED'
        ))
);

-- 29. PAYMENTS
CREATE TABLE payments
(
    id                 BIGSERIAL PRIMARY KEY,
    order_id           BIGINT         NOT NULL,
    transaction_code   VARCHAR(50)    NOT NULL,
    payment_method     VARCHAR(20)    NOT NULL,
    amount             NUMERIC(15, 2) NOT NULL,
    status             VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
    vnp_txn_ref        VARCHAR(50),
    vnp_transaction_no VARCHAR(50),
    vnp_bank_code      VARCHAR(30),
    vnp_response_code  VARCHAR(10),
    vnp_pay_date       VARCHAR(20),
    raw_payload        JSONB,
    paid_at            TIMESTAMPTZ,
    created_at         TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_payments_tx_code UNIQUE (transaction_code),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE RESTRICT,
    CONSTRAINT chk_payments_method CHECK (payment_method IN ('COD', 'VNPAY')),
    CONSTRAINT chk_payments_status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'))
);

CREATE UNIQUE INDEX uk_payments_vnp_txn_ref ON payments (vnp_txn_ref) WHERE vnp_txn_ref IS NOT NULL;
CREATE INDEX idx_payments_order ON payments (order_id);

-- 30. REVIEWS
CREATE TABLE reviews
(
    id            BIGSERIAL PRIMARY KEY,
    user_id       BIGINT      NOT NULL,
    product_id    BIGINT      NOT NULL,
    variant_id    BIGINT      NOT NULL,
    order_item_id BIGINT      NOT NULL,
    rating        SMALLINT    NOT NULL,
    comment       TEXT,
    images_json   JSONB       NOT NULL DEFAULT '[]'::jsonb,
    is_visible    BOOLEAN     NOT NULL DEFAULT TRUE,
    admin_reply   TEXT,
    replied_at    TIMESTAMPTZ,
    replied_by    BIGINT,
    is_deleted    BOOLEAN     NOT NULL DEFAULT FALSE,
    deleted_at    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_reviews_order_item UNIQUE (order_item_id),
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_variant FOREIGN KEY (variant_id) REFERENCES product_variants (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_order_item FOREIGN KEY (order_item_id) REFERENCES order_items (id) ON DELETE RESTRICT,
    CONSTRAINT fk_reviews_replier FOREIGN KEY (replied_by) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT chk_reviews_rating CHECK (rating >= 1 AND rating <= 5)
);

CREATE INDEX idx_reviews_product_visible ON reviews (product_id, rating, created_at DESC)
    WHERE is_visible = TRUE AND is_deleted = FALSE;

-- 31. WISHLISTS
CREATE TABLE wishlists
(
    id         BIGSERIAL PRIMARY KEY,
    user_id    BIGINT      NOT NULL,
    product_id BIGINT      NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uk_wishlists_user_product UNIQUE (user_id, product_id),
    CONSTRAINT fk_wishlists_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlists_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
);