-- Add missing columns to existing stories table
ALTER TABLE stories 
ADD COLUMN IF NOT EXISTS current_page INTEGER NOT NULL DEFAULT 1,
ADD COLUMN IF NOT EXISTS is_complete BOOLEAN NOT NULL DEFAULT FALSE;

-- Create indexes for new columns
CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id);
CREATE INDEX IF NOT EXISTS idx_stories_current_page ON stories(current_page);

-- Update existing stories to set current_page based on their pages count
UPDATE stories 
SET current_page = COALESCE(
  (SELECT COUNT(*) FROM pages WHERE pages.story_id = stories.id), 
  1
);

-- Update existing stories to set is_complete based on current_page vs total_pages
UPDATE stories 
SET is_complete = (current_page >= total_pages);
