-- Add email and desktop notification columns to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email_notifications_enabled BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS desktop_notifications_enabled BOOLEAN DEFAULT true;

-- Add last_online column for online status tracking
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS last_online TIMESTAMP WITH TIME ZONE;
