-- Create merchandise table
CREATE TABLE IF NOT EXISTS merchandise (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price TEXT NOT NULL,
  color TEXT NOT NULL,
  tier TEXT NOT NULL CHECK (tier IN ('platinum', 'gold', 'silver')),
  images TEXT[] DEFAULT ARRAY[]::TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on tier for faster filtering
CREATE INDEX IF NOT EXISTS merchandise_tier_idx ON merchandise(tier);

-- Create index on title for searching
CREATE INDEX IF NOT EXISTS merchandise_title_idx ON merchandise(title);

-- Enable Row Level Security
ALTER TABLE merchandise ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all users to read merchandise
CREATE POLICY "Allow public read access to merchandise"
  ON merchandise FOR SELECT
  USING (true);

-- Create policy to allow creator to insert/update/delete merchandise
-- Note: You'll need to replace 'tlive4444@gmail.com' with the actual creator email
CREATE POLICY "Allow creator to manage merchandise"
  ON merchandise FOR ALL
  USING (
    auth.uid() IN (
      SELECT id FROM profiles 
      WHERE email = 'tlive4444@gmail.com' 
         OR display_name ILIKE '%ninskie%'
    )
  );

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_merchandise_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER merchandise_updated_at_trigger
  BEFORE UPDATE ON merchandise
  FOR EACH ROW
  EXECUTE FUNCTION update_merchandise_updated_at();

-- Insert default merchandise items
INSERT INTO merchandise (title, description, price, color, tier, images) VALUES
  ('Limited-Run Tote Bag', 'Limited-run tote bags with unique designs', '25', '#FFB7C5', 'platinum', ARRAY[]::TEXT[]),
  ('Seasonal Bundle', 'Seasonal bundles with limited edition packaging', '59', '#FFB7C5', 'platinum', ARRAY[]::TEXT[]),
  ('Early Access Capsule', 'Early access to capsule collections', '45', '#FFB7C5', 'platinum', ARRAY[]::TEXT[]),
  ('Weatherboo Gift Items', 'Weatherboo gift items perfect for friends and yourself', '35', '#FFB7C5', 'platinum', ARRAY[]::TEXT[]),
  ('Premium Exclusive Merchandise', 'Premium exclusive merchandise', '49', '#FFB7C5', 'platinum', ARRAY[]::TEXT[]),
  ('Special Edition Collectibles', 'Special edition collectibles', '39', '#FFB7C5', 'platinum', ARRAY[]::TEXT[]),
  ('Weathery Tee', 'Soft pastel tee with weather motif', '29', '#E6E6FA', 'gold', ARRAY[]::TEXT[]),
  ('Cozy Cloud Hoodie', 'Cozy hoodies for cool, misty mornings', '39', '#E6E6FA', 'gold', ARRAY[]::TEXT[]),
  ('Weather Beanies', 'Cozy beanies for misty weather', '22', '#E6E6FA', 'gold', ARRAY[]::TEXT[]),
  ('Soft Pastel Tees', 'Handpicked designs inspired by weather moods', '27', '#E6E6FA', 'gold', ARRAY[]::TEXT[]),
  ('Standard Apparel Items', 'Standard apparel items', '32', '#E6E6FA', 'gold', ARRAY[]::TEXT[]),
  ('Sky Tote', 'Sunny tote bag for carrying your favorite weather journal', '19', '#87CEEB', 'silver', ARRAY[]::TEXT[]),
  ('Weather-themed Stickers', 'Weather-themed stickers for everyday joy', '8', '#87CEEB', 'silver', ARRAY[]::TEXT[]),
  ('Standard Tote Bags', 'Standard tote bags with weather motifs', '15', '#87CEEB', 'silver', ARRAY[]::TEXT[]),
  ('Basic Weather Accessories', 'Basic weather accessories', '12', '#87CEEB', 'silver', ARRAY[]::TEXT[])
ON CONFLICT DO NOTHING;
