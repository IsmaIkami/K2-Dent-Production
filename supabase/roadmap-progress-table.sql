-- ============================================
-- K2 Dental Cockpit - Roadmap Progress Tracking
-- Author: Ismail Sialyen
-- Date: 2026-07-24
-- Purpose: Track roadmap epic/task completion per user
-- ============================================

-- Table: roadmap_progress
-- Store user progress on roadmap tasks
CREATE TABLE IF NOT EXISTS roadmap_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    task_id VARCHAR(50) NOT NULL, -- Ex: "task-1-1", "task-2-3"
    epic_id VARCHAR(50) NOT NULL, -- Ex: "epic-1", "epic-2"
    phase_id VARCHAR(20) NOT NULL, -- "phase-1" ou "phase-2"
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, task_id)
);

-- Index pour performance
CREATE INDEX idx_roadmap_user ON roadmap_progress(user_id);
CREATE INDEX idx_roadmap_phase ON roadmap_progress(phase_id);
CREATE INDEX idx_roadmap_epic ON roadmap_progress(epic_id);
CREATE INDEX idx_roadmap_completed ON roadmap_progress(completed);

-- RLS Policies
ALTER TABLE roadmap_progress ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own progress
CREATE POLICY "Users can view own progress"
    ON roadmap_progress
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own progress
CREATE POLICY "Users can insert own progress"
    ON roadmap_progress
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own progress
CREATE POLICY "Users can update own progress"
    ON roadmap_progress
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own progress
CREATE POLICY "Users can delete own progress"
    ON roadmap_progress
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- VIEW: Roadmap Summary per User
-- ============================================
CREATE OR REPLACE VIEW roadmap_summary AS
SELECT
    user_id,
    phase_id,
    epic_id,
    COUNT(*) AS total_tasks,
    COUNT(*) FILTER (WHERE completed = true) AS completed_tasks,
    ROUND(
        (COUNT(*) FILTER (WHERE completed = true)::DECIMAL / COUNT(*)) * 100,
        2
    ) AS completion_percentage,
    MAX(completed_at) AS last_completed_at
FROM roadmap_progress
GROUP BY user_id, phase_id, epic_id;

-- ============================================
-- FUNCTION: Update roadmap progress
-- ============================================
CREATE OR REPLACE FUNCTION update_roadmap_task(
    p_task_id VARCHAR(50),
    p_epic_id VARCHAR(50),
    p_phase_id VARCHAR(20),
    p_completed BOOLEAN,
    p_notes TEXT DEFAULT NULL
)
RETURNS roadmap_progress AS $$
DECLARE
    v_progress roadmap_progress;
BEGIN
    -- Upsert task progress
    INSERT INTO roadmap_progress (
        user_id,
        task_id,
        epic_id,
        phase_id,
        completed,
        completed_at,
        notes,
        updated_at
    ) VALUES (
        auth.uid(),
        p_task_id,
        p_epic_id,
        p_phase_id,
        p_completed,
        CASE WHEN p_completed THEN NOW() ELSE NULL END,
        p_notes,
        NOW()
    )
    ON CONFLICT (user_id, task_id)
    DO UPDATE SET
        completed = p_completed,
        completed_at = CASE WHEN p_completed THEN NOW() ELSE NULL END,
        notes = COALESCE(p_notes, roadmap_progress.notes),
        updated_at = NOW()
    RETURNING * INTO v_progress;

    RETURN v_progress;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: Get user roadmap progress
-- ============================================
CREATE OR REPLACE FUNCTION get_roadmap_progress()
RETURNS TABLE (
    task_id VARCHAR(50),
    epic_id VARCHAR(50),
    phase_id VARCHAR(20),
    completed BOOLEAN,
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        rp.task_id,
        rp.epic_id,
        rp.phase_id,
        rp.completed,
        rp.completed_at,
        rp.notes
    FROM roadmap_progress rp
    WHERE rp.user_id = auth.uid()
    ORDER BY rp.phase_id, rp.epic_id, rp.task_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: Get epic completion percentage
-- ============================================
CREATE OR REPLACE FUNCTION get_epic_completion(p_epic_id VARCHAR(50))
RETURNS DECIMAL AS $$
DECLARE
    v_percentage DECIMAL;
BEGIN
    SELECT
        CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE ROUND(
                (COUNT(*) FILTER (WHERE completed = true)::DECIMAL / COUNT(*)) * 100,
                2
            )
        END INTO v_percentage
    FROM roadmap_progress
    WHERE user_id = auth.uid()
      AND epic_id = p_epic_id;

    RETURN COALESCE(v_percentage, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: Get phase completion percentage
-- ============================================
CREATE OR REPLACE FUNCTION get_phase_completion(p_phase_id VARCHAR(20))
RETURNS DECIMAL AS $$
DECLARE
    v_percentage DECIMAL;
BEGIN
    SELECT
        CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE ROUND(
                (COUNT(*) FILTER (WHERE completed = true)::DECIMAL / COUNT(*)) * 100,
                2
            )
        END INTO v_percentage
    FROM roadmap_progress
    WHERE user_id = auth.uid()
      AND phase_id = p_phase_id;

    RETURN COALESCE(v_percentage, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- SAMPLE DATA (Development)
-- Uncomment to insert sample progress for testing
-- ============================================
/*
-- Example: Mark some tasks as completed for current user
INSERT INTO roadmap_progress (user_id, task_id, epic_id, phase_id, completed, completed_at) VALUES
(auth.uid(), 'task-1-1', 'epic-1', 'phase-1', true, NOW()),
(auth.uid(), 'task-1-2', 'epic-1', 'phase-1', true, NOW()),
(auth.uid(), 'task-1-3', 'epic-1', 'phase-1', false, NULL);
*/

-- ============================================
-- GRANTS
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON roadmap_progress TO authenticated;
GRANT SELECT ON roadmap_summary TO authenticated;
GRANT EXECUTE ON FUNCTION update_roadmap_task(VARCHAR, VARCHAR, VARCHAR, BOOLEAN, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_roadmap_progress() TO authenticated;
GRANT EXECUTE ON FUNCTION get_epic_completion(VARCHAR) TO authenticated;
GRANT EXECUTE ON FUNCTION get_phase_completion(VARCHAR) TO authenticated;

-- ============================================
-- VALIDATION QUERIES
-- ============================================
-- Check table exists
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'roadmap_progress';

-- Check RLS enabled
SELECT tablename, rowsecurity FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'roadmap_progress';

-- Check policies
SELECT policyname, cmd FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'roadmap_progress';

-- ============================================
-- NOTES
-- ============================================
-- 1. Run this SQL in Supabase SQL Editor
-- 2. Table is optional - roadmap.html works with LocalStorage by default
-- 3. Enable DB sync by uncommenting sync code in roadmap.html
-- 4. Test with: SELECT * FROM get_roadmap_progress();
-- ============================================
