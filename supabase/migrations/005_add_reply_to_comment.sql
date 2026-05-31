-- Add reply_to_text column to buddy_comments for threaded replies
ALTER TABLE public.buddy_comments
ADD COLUMN IF NOT EXISTS reply_to_text TEXT;
