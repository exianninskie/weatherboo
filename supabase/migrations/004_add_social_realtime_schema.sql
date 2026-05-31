-- Add online presence support and social tables for realtime community features

-- Add is_online column to profiles for presence tracking
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT false;

-- Create community posts table
CREATE TABLE IF NOT EXISTS public.community_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL,
  avatar TEXT,
  content TEXT NOT NULL,
  weather TEXT,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS community_posts_user_id_idx ON public.community_posts(user_id);
CREATE INDEX IF NOT EXISTS community_posts_created_at_idx ON public.community_posts(created_at DESC);

-- Create buddy comments table
CREATE TABLE IF NOT EXISTS public.buddy_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipient_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE INDEX IF NOT EXISTS buddy_comments_recipient_id_idx ON public.buddy_comments(recipient_id);
CREATE INDEX IF NOT EXISTS buddy_comments_author_id_idx ON public.buddy_comments(author_id);
CREATE INDEX IF NOT EXISTS buddy_comments_created_at_idx ON public.buddy_comments(created_at ASC);

-- Enable RLS for the new tables
ALTER TABLE public.community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.buddy_comments ENABLE ROW LEVEL SECURITY;

-- Community posts policies
DROP POLICY IF EXISTS "Users can view community posts" ON public.community_posts;
DROP POLICY IF EXISTS "Users can insert community posts" ON public.community_posts;
DROP POLICY IF EXISTS "Users can update own community posts" ON public.community_posts;
DROP POLICY IF EXISTS "Users can delete own community posts" ON public.community_posts;

CREATE POLICY "Users can view community posts"
  ON public.community_posts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert community posts"
  ON public.community_posts FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own community posts"
  ON public.community_posts FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own community posts"
  ON public.community_posts FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Buddy comments policies
DROP POLICY IF EXISTS "Users can view buddy comments" ON public.buddy_comments;
DROP POLICY IF EXISTS "Users can insert buddy comments" ON public.buddy_comments;
DROP POLICY IF EXISTS "Users can update own buddy comments" ON public.buddy_comments;
DROP POLICY IF EXISTS "Users can delete own buddy comments" ON public.buddy_comments;

CREATE POLICY "Users can view buddy comments"
  ON public.buddy_comments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert buddy comments"
  ON public.buddy_comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can update own buddy comments"
  ON public.buddy_comments FOR UPDATE
  TO authenticated
  USING (auth.uid() = author_id)
  WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Users can delete own buddy comments"
  ON public.buddy_comments FOR DELETE
  TO authenticated
  USING (auth.uid() = author_id);

-- Update profiles select policy so authenticated users can see online profiles
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;

CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can view public online profiles"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (is_online = true);
