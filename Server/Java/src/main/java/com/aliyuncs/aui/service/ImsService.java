package com.aliyuncs.aui.service;

import com.aliyuncs.aui.dto.req.AIAgentStartRequestDto;
import com.aliyuncs.aui.dto.req.AiAgentStopRequestDto;
import com.aliyuncs.aui.dto.req.AiAgentUpdateRequestDto;
import com.aliyuncs.aui.dto.req.GenerateAIAgentCallRequestDto;
import com.aliyuncs.aui.dto.res.AiAgentStartResponse;
import com.aliyuncs.aui.dto.res.GenerateAIAgentCallResponse;

/**
 * IMS管理服务
 *
 * @author chunlei.zcl
 */
public interface ImsService {

    AiAgentStartResponse startAIAgentInstance(AIAgentStartRequestDto aiAgentStartRequestDto);

    boolean stopAIAgentInstance(AiAgentStopRequestDto aiAgentStopRequestDto);

    boolean updateAIAgentInstance(AiAgentUpdateRequestDto robotUpdateRequestDto);

    GenerateAIAgentCallResponse generateAIAgentCall(GenerateAIAgentCallRequestDto generateAIAgentCallRequestDto);
}

