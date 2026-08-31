-- =====================================================
-- A/B TEST RESULTS TABLE

-- P-values for tests 2 and 3 came back smaller than
-- DECIMAL(12,10) can represent (true values are on the
-- order of 1e-72 and 1e-47), so they are stored as the
-- smallest representable value with a note in the
-- comments. All three tests are far below the p < 0.05
-- significance threshold either way.
-- =====================================================

USE ecommerce_analytics;

CREATE TABLE ABTestResults (
    TestID          INT AUTO_INCREMENT PRIMARY KEY,
    TestName        VARCHAR(100) NOT NULL,
    GroupAName      VARCHAR(100) NOT NULL,
    GroupAMetric    DECIMAL(6,4) NOT NULL,
    GroupASize      INT NOT NULL,
    GroupBName      VARCHAR(100) NOT NULL,
    GroupBMetric    DECIMAL(6,4) NOT NULL,
    GroupBSize      INT NOT NULL,
    PValue          DECIMAL(12,10) NOT NULL,
    IsSignificant   BOOLEAN NOT NULL,
    Recommendation  VARCHAR(255),
    DataSource      ENUM('real','simulated') NOT NULL
);

-- Real numbers, computed directly from the notebook's datasets
INSERT INTO ABTestResults
    (TestName, GroupAName, GroupAMetric, GroupASize, GroupBName, GroupBMetric, GroupBSize, PValue, IsSignificant, Recommendation, DataSource)
VALUES
    -- p < 0.001 as reported in the notebook (real Kaggle dataset, 588K rows)
    ('Clear vs Unclear Messaging',
     'Unclear messaging', 0.0179, 264000,
     'Clear messaging', 0.0255, 264000,
     0.0010000000, TRUE, 'Ship the change', 'real'),

    -- true p-value ~1.23e-72, stored at smallest representable precision
    ('Guest Checkout vs Forced Signup',
     'Forced signup', 0.4222, 5000,
     'Guest checkout', 0.6026, 5000,
     0.0000000001, TRUE, 'Ship the change', 'simulated'),

    -- true p-value ~7.12e-47, stored at smallest representable precision
    ('Short vs Long Checkout Form',
     'Long form', 0.4978, 5000,
     'Short form', 0.6404, 5000,
     0.0000000001, TRUE, 'Ship the change', 'simulated');

-- Verify:
-- SELECT * FROM ABTestResults;
