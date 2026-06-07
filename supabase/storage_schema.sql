-- Create storage bucket for merchandise images
-- Note: This needs to be run in the Supabase SQL editor
-- Alternatively, you can create the bucket through the Supabase Dashboard under Storage

INSERT INTO storage.buckets (id, name, public)
VALUES ('merchandise_images', 'merchandise_images', true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  public = EXCLUDED.public;

-- Create policy to allow public read access to merchandise images
CREATE POLICY "Allow public read access to merchandise_images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'merchandise_images');

-- Create policy to allow creator to upload merchandise images
CREATE POLICY "Allow creator to upload merchandise_images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'merchandise_images' AND
    auth.uid() IN (
      SELECT id FROM profiles 
      WHERE email = 'tlive4444@gmail.com' 
         OR display_name ILIKE '%ninskie%'
    )
  );

-- Create policy to allow creator to delete merchandise images
CREATE POLICY "Allow creator to delete merchandise_images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'merchandise_images' AND
    auth.uid() IN (
      SELECT id FROM profiles 
      WHERE email = 'tlive4444@gmail.com' 
         OR display_name ILIKE '%ninskie%'
    )
  );
