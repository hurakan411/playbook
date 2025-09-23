-- Stories table
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  total_pages INTEGER NOT NULL DEFAULT 5,
  current_page INTEGER NOT NULL DEFAULT 1,
  is_complete BOOLEAN NOT NULL DEFAULT FALSE,
  art_style TEXT NOT NULL DEFAULT 'watercolor',
  main_character_name TEXT NOT NULL,
  user_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pages table
CREATE TABLE pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  page_number INTEGER NOT NULL,
  text TEXT NOT NULL,
  image_prompt TEXT NOT NULL,
  image_url TEXT,
  image_storage_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(story_id, page_number)
);

-- Indexes for performance
CREATE INDEX idx_pages_story_id ON pages(story_id);
CREATE INDEX idx_pages_story_page ON pages(story_id, page_number);
CREATE INDEX idx_stories_created_at ON stories(created_at DESC);
CREATE INDEX idx_stories_user_id ON stories(user_id);
CREATE INDEX idx_stories_current_page ON stories(current_page);

-- RLS (Row Level Security) policies
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE pages ENABLE ROW LEVEL SECURITY;

-- Allow all operations for service role (backend API)
CREATE POLICY "Service role can do everything on stories" ON stories
  FOR ALL USING (auth.role() = 'service_role');

CREATE POLICY "Service role can do everything on pages" ON pages
  FOR ALL USING (auth.role() = 'service_role');

-- Storage bucket for images
INSERT INTO storage.buckets (id, name, public) 
VALUES ('story-images', 'story-images', true);

-- Storage policy
CREATE POLICY "Service role can upload images" ON storage.objects
  FOR ALL USING (bucket_id = 'story-images' AND auth.role() = 'service_role');
