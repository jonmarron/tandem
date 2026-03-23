import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

import type { Database } from './types/database';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

const isConfigured = supabaseUrl.startsWith('http') && supabaseAnonKey.length > 0;

if (__DEV__ && !isConfigured) {
  console.warn(
    '[Supabase] Missing env vars — copy .env.local.example to .env.local and restart the bundler with --clear.'
  );
}

// Use SecureStore on native, localStorage on web
const ExpoSecureStoreAdapter = {
  getItem: (key: string) => {
    if (Platform.OS === 'web') return Promise.resolve(localStorage.getItem(key));
    return SecureStore.getItemAsync(key);
  },
  setItem: (key: string, value: string) => {
    if (Platform.OS === 'web') { localStorage.setItem(key, value); return Promise.resolve(); }
    return SecureStore.setItemAsync(key, value);
  },
  removeItem: (key: string) => {
    if (Platform.OS === 'web') { localStorage.removeItem(key); return Promise.resolve(); }
    return SecureStore.deleteItemAsync(key);
  },
};

export const supabase = createClient<Database>(
  supabaseUrl || 'http://localhost',
  supabaseAnonKey || 'placeholder',
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: isConfigured,
      persistSession: isConfigured,
      detectSessionInUrl: false,
    },
    global: {
      fetch: (url, options) =>
        Promise.race([
          fetch(url, options),
          new Promise<never>((_, reject) =>
            setTimeout(() => reject(new Error('Supabase request timed out')), 10000)
          ),
        ]),
    },
  }
);
