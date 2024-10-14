import { create } from 'zustand';

import { AICallAgentState, AICallAgentType, AICallState } from 'aliyun-auikit-aicall';
import { AICallSubtitleData } from 'aliyun-auikit-aicall';

type SubtitleItem = {
  data: AICallSubtitleData;
  source: 'agent' | 'user';
};

interface CallStore {
  // 通话状态
  callState: AICallState;
  // 通话错误
  callErrorMessage?: string;

  agentType: AICallAgentType;

  // Agent 状态
  agentState: AICallAgentState;

  // 是否正在说话
  isSpeaking: boolean;

  // 字幕
  currentSubtitle?: SubtitleItem;
  currentAgentSubtitle?: SubtitleItem;
  subtitleList: SubtitleItem[];
  setCurrentSubtitle: (subtitle: SubtitleItem) => void;

  enableVoiceInterrupt: boolean;
  updatingVoiceInterrupt: boolean;

  voiceId: string;
  updatingVoiceId: boolean;

  microphoneMuted: boolean;

  reset: () => void;
}

const initialCallState: Omit<CallStore, 'setCurrentSubtitle' | 'reset'> = {
  callState: AICallState.None,
  agentType: AICallAgentType.VoiceAgent,
  agentState: AICallAgentState.Listening,
  isSpeaking: false,
  currentSubtitle: undefined,
  currentAgentSubtitle: undefined,
  subtitleList: [],
  enableVoiceInterrupt: true,
  updatingVoiceInterrupt: false,
  voiceId: 'zhixiaoxia',
  updatingVoiceId: false,
  microphoneMuted: false,
};

const useCallStore = create<CallStore>((set) => ({
  ...initialCallState,
  setCurrentSubtitle: (subtitle) =>
    set((state: CallStore) => {
      let newSubtitle = subtitle;

      const currentAgentSubtitle = state.currentAgentSubtitle;
      const newState: Partial<CallStore> = {};
      // agent 的字幕连续出现，sentenceId 相同进行拼接
      if (subtitle.source === 'agent' && subtitle.data.sentenceId === currentAgentSubtitle?.data?.sentenceId) {
        currentAgentSubtitle.data.text = currentAgentSubtitle.data.text + subtitle.data.text;
        currentAgentSubtitle.data.end = subtitle.data.end;
        newState.currentAgentSubtitle = currentAgentSubtitle;
        newSubtitle = currentAgentSubtitle;
      } else {
        // agent 字幕
        if (subtitle.source === 'agent') {
          // 如果 currentAgentSubtitle 存在，并且非 end 则添加到 subtitleList，视为已经 end
          if (currentAgentSubtitle?.data.text && !currentAgentSubtitle.data.end) {
            newState.subtitleList = [...state.subtitleList, currentAgentSubtitle];
          }
          newState.currentAgentSubtitle = subtitle;
        }
        newSubtitle = subtitle;
      }

      newState.currentSubtitle = { ...newSubtitle };

      // 如果 end 则添加到 subtitleList
      if (newSubtitle.data.end && newSubtitle.data.text) {
        newState.subtitleList = [...state.subtitleList, newSubtitle];
      }
      return newState;
    }),
  reset: () => {
    set(initialCallState);
  },
}));

export default useCallStore;