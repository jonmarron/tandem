import { Link } from 'expo-router';
import { useState } from 'react';
import { ActivityIndicator, Pressable, Text, TextInput, View } from 'react-native';

import { useAuth } from '@/lib/auth';

export default function LoginScreen() {
  const { signIn } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSignIn() {
    if (!email || !password) {
      setError('Please enter your email and password.');
      return;
    }
    setLoading(true);
    setError(null);
    const { error } = await signIn(email.trim(), password);
    setLoading(false);
    if (error) setError(error);
  }

  return (
    <View className="flex-1 justify-center bg-background px-6">
      <Text className="text-3xl font-bold text-text-primary mb-1">Welcome back</Text>
      <Text className="text-base text-text-secondary mb-8">Sign in to FamilyMatch</Text>

      <Text className="text-sm font-medium text-text-primary mb-1">Email</Text>
      <TextInput
        className="bg-surface border border-border rounded-xl px-4 py-3 text-text-primary mb-4"
        placeholder="you@example.com"
        placeholderTextColor="#9CA3AF"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />

      <Text className="text-sm font-medium text-text-primary mb-1">Password</Text>
      <TextInput
        className="bg-surface border border-border rounded-xl px-4 py-3 text-text-primary mb-4"
        placeholder="••••••••"
        placeholderTextColor="#9CA3AF"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />

      {error && (
        <Text className="text-error text-sm mb-4">{error}</Text>
      )}

      <Pressable
        className="bg-primary rounded-xl py-4 items-center mb-4"
        onPress={handleSignIn}
        disabled={loading}
      >
        {loading
          ? <ActivityIndicator color="#fff" />
          : <Text className="text-white font-semibold text-base">Sign in</Text>
        }
      </Pressable>

      <View className="flex-row justify-center">
        <Text className="text-text-secondary">Don't have an account? </Text>
        <Link href="/(auth)/signup">
          <Text className="text-primary font-semibold">Sign up</Text>
        </Link>
      </View>
    </View>
  );
}
