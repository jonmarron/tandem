import { Pressable, Text, View } from 'react-native';

import { useAuth } from '@/lib/auth';

// useProfile hook is wired up here once the auth flow lands (issue #6).
// React Query provider is active — queries will work once a session exists.
export default function ProfileScreen() {
  const { user, signOut } = useAuth();

  return (
    <View className="flex-1 items-center justify-center bg-background px-6">
      <View className="bg-surface rounded-2xl p-6 shadow-sm items-center w-full mb-6">
        <Text className="text-2xl font-bold text-text-primary">Profile</Text>
        {user && (
          <Text className="text-base text-text-secondary mt-2">{user.email}</Text>
        )}
      </View>

      <Pressable
        className="bg-error rounded-xl py-4 items-center w-full"
        onPress={signOut}
      >
        <Text className="text-white font-semibold text-base">Log out</Text>
      </Pressable>
    </View>
  );
}
